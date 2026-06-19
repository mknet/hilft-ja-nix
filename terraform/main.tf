# Terraform Konfiguration für Hetzner Cloud + NixOS Akkoma Server
terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
  }
}

# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# SSH Key für Zugriff
resource "hcloud_ssh_key" "default" {
  name       = "nixos-akkoma-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Server erstellen
resource "hcloud_server" "akkoma" {
  name        = "nixos-akkoma-server"
  image       = "ubuntu-20.04"
  server_type = "cx21"  # 2 vCPU, 4 GB RAM
  location    = "fsn1"  # Falkenstein
  ssh_keys    = [hcloud_ssh_key.default.id]
  
  # User Data für NixOS Installation
  # TODO: auf nixos-anywhere --flake .#helferlein umstellen
  user_data = templatefile("${path.module}/user-data.sh", {
    environment_nix = file("${path.module}/../environment.nix")
  })

  # Firewall Regeln
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

# Firewall für SSH, HTTP, HTTPS
resource "hcloud_firewall" "akkoma" {
  name = "akkoma-firewall"
  
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  
  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  
  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  
  rule {
    direction  = "in"
    port       = "5432"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall dem Server zuweisen
resource "hcloud_firewall_attachment" "akkoma" {
  firewall_id = hcloud_firewall.akkoma.id
  server_ids  = [hcloud_server.akkoma.id]
}

# Output
output "server_ip" {
  value = hcloud_server.akkoma.ipv4_address
}

output "server_name" {
  value = hcloud_server.akkoma.name
}

output "ssh_command" {
  value = "ssh root@${hcloud_server.akkoma.ipv4_address}"
}
