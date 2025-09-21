{ config, pkgs, lib, ... }:

# Minimale Konfiguration für ersten Test
let
  env = import ./environment.nix;
in

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  # Boot-Konfiguration
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    
    initrd.availableKernelModules = [ 
      "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" 
      "ext4" "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Netzwerk
  networking = {
    hostName = env.current.hostname;
    domain = env.current.domain;
    fqdn = "${env.current.hostname}.${env.current.domain}";
    useDHCP = lib.mkDefault true;
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Basis-Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # PostgreSQL (minimal)
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "akkoma" ];
    ensureUsers = [
      {
        name = "akkoma";
        ensureDBOwnership = true;
      }
    ];
  };

  # Nginx (minimal)
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      root = "/var/www/html";
      locations."/" = {
        index = "index.html";
      };
    };
  };

  # System-Version
  system.stateVersion = "23.11";
}
