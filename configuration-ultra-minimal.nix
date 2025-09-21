{ config, pkgs, lib, ... }:

# Ultra-minimale Konfiguration - nur NixOS Basis
{
  imports = [
    # Hardware-Konfiguration wird automatisch generiert
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
    hostName = "akkoma-server";
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

  # System-Version
  system.stateVersion = "23.11";
}
