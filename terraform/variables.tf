# Terraform Variablen für Hetzner Cloud

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name des Servers"
  type        = string
  default     = "nixos-akkoma-server"
}

variable "server_type" {
  description = "Server-Typ (cx11, cx21, cx31, etc.)"
  type        = string
  default     = "cx21"  # 2 vCPU, 4 GB RAM
}

variable "location" {
  description = "Hetzner Cloud Standort"
  type        = string
  default     = "fsn1"  # Falkenstein
}

variable "domain" {
  description = "Domain für den Akkoma Server"
  type        = string
  default     = "example.com"
}

variable "email" {
  description = "E-Mail für Let's Encrypt"
  type        = string
  default     = "admin@example.com"
}
