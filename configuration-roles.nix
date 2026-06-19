# Modulare NixOS Konfiguration mit Rollen
{ config, pkgs, lib, ... }:

let
  env = import ./environment.nix;
in

{
  imports = [
    # Rollen importieren
    ./roles/postgresql.nix
    ./roles/redis.nix
    ./roles/nginx.nix
    ./roles/akkoma.nix
    ./roles/jitsi.nix
  ];

  # Boot-Konfiguration
  boot = {
    loader.grub = {
      enable = lib.mkDefault true;
      device = lib.mkDefault "/dev/sda";
      useOSProber = true;
    };

    initrd.availableKernelModules = [
      "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod"
      "ext4" "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Networking
  networking = {
    hostName = env.current.hostname;
    domain = env.current.domain;
    fqdn = "${env.current.hostname}.${env.current.domain}";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
      ];
    };
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # ACME (Let's Encrypt)
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = env.current.email;
    };
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    jails = {
      nginx-http-auth = {
        enable = true;
        port = "http,https";
        filter = "nginx-http-auth";
        logpath = "/var/log/nginx/error.log";
        maxretry = 5;
        findtime = "1m";
        bantime = "10m";
      };
    };
  };

  # Rollen aktivieren
  roles.postgresql = {
    enable = true;
    databases = [ env.current.database.name "${env.current.database.name}_test" ];
    users = [{
      name = env.current.database.user;
      databases = [ env.current.database.name "${env.current.database.name}_test" ];
    }];
  };

  roles.redis = {
    enable = true;
    port = 6379;
  };

  roles.nginx = {
    enable = true;
    enableACME = true;
    virtualHosts = {
      localhost = {
        domain = "localhost";
        root = "/var/www/html";
        proxyPass = null;
      };
    };
  };

  roles.akkoma = {
    enable = true;
    domain = env.current.domain;
    hostname = env.current.hostname;
    email = env.current.email;
    database = env.current.database.name;
    databaseUser = env.current.database.user;
    secret = env.current.akkoma.secret;
  };

  roles.jitsi = {
    enable = true;
    domain = env.current.domain;
    hostname = "meet";
  };

  # System Version
  system.stateVersion = "23.11";
}
