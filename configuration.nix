{ config, pkgs, lib, ... }:

# Importiere Umgebungsvariablen
let
  env = import ./environment.nix;
in

{
  imports = [
    # Hardware-Konfiguration (wird automatisch generiert)
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  # Boot-Konfiguration
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";  # Anpassen für Ihre Hardware
      useOSProber = true;
    };
    
    # Kernel-Module für Virtualisierung
    initrd.availableKernelModules = [ 
      "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" 
      "ext4" "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Netzwerk-Konfiguration
  networking = {
    hostName = env.current.hostname;
    domain = env.current.domain;
    fqdn = "${env.current.hostname}.${env.current.domain}";
    useDHCP = lib.mkDefault true;
    
    # Firewall-Regeln
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22    # SSH
        80    # HTTP
        443   # HTTPS
        5432  # PostgreSQL
        5222  # XMPP (Jitsi)
        5269  # XMPP (Jitsi)
        5280  # XMPP (Jitsi)
        5347  # TURN (Jitsi)
        10000 # Jitsi Meet
        10001 # Jitsi Meet
      ];
      allowedUDPPorts = [ 
        10000 # Jitsi Meet
        10001 # Jitsi Meet
      ];
    };
  };

  # System-Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    nano
  ];

  # OpenSSH für Remote-Zugriff
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;  # SSH-Keys verwenden
    };
  };

  # PostgreSQL Datenbank
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    
    # Datenbanken erstellen
    ensureDatabases = [ 
      env.current.database.name 
      "${env.current.database.name}_test" 
    ];
    
    # Benutzer erstellen
    ensureUsers = [
      {
        name = env.current.database.user;
        ensureDBOwnership = true;
      }
    ];
  };

  # Redis für Caching
  services.redis = {
    enable = true;
    servers."" = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
    };
  };

  # Nginx Web Server
  services.nginx = {
    enable = true;
    
    # Virtual Hosts
    virtualHosts = {
      "localhost" = {
        root = "/var/www/html";
        locations."/" = {
          index = "index.html";
        };
      };
      
      "akkoma.${env.current.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:4000";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Akkoma (Fediverse Server)
  services.akkoma = {
    enable = true;
    initSecrets = [ "secret" ];
    config = {
      ":pleroma" = {
        ":instance" = {
          name = "Akkoma Server";
          email = env.current.email;
          description = "Akkoma instance running on NixOS";
        };
        ":database" = {
          hostname = "localhost";
          database = env.current.database.name;
          username = env.current.database.user;
        };
      };
    };
  };

  # Jitsi Meet
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.${env.current.domain}";
    
    # Konfiguration
    config = {
      enableWelcomePage = true;
      enableInsecureRoomNameWarning = false;
      enableNoisyMicDetection = true;
    };
  };

  # Fail2ban für Sicherheit
  services.fail2ban = {
    enable = true;
    jails = {
      "nginx-http-auth" = ''
        enabled = true
        port = http,https
        filter = nginx-http-auth
        logpath = /var/log/nginx/error.log
        maxretry = 6
      '';
    };
  };

  # Let's Encrypt Zertifikate
  security.acme = {
    acceptTerms = true;
    defaults.email = env.current.email;
  };

  # Sudo-Konfiguration
  security.sudo.wheelNeedsPassword = false;

  # Docker für Container
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Insecure Pakete erlauben (falls nötig)
  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8043"
  ];

  # System-Version
  system.stateVersion = "23.11";
}