# NixOS Minimal Installation ISO
# Diese Konfiguration erstellt ein funktionierendes NixOS ISO

{ config, pkgs, ... }:

# NixOS Akkoma Server ISO mit allen Services
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  # System Version
  system.stateVersion = "23.11";

  # PostgreSQL Datenbank
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    
    # Datenbanken erstellen
    ensureDatabases = [ 
      "akkoma" 
      "akkoma_test" 
    ];
    
    # Benutzer erstellen
    ensureUsers = [
      {
        name = "akkoma";
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
      
      "akkoma.example.com" = {
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
          email = "admin@example.com";
          description = "Akkoma instance running on NixOS";
        };
        ":database" = {
          hostname = "localhost";
          database = "akkoma";
          username = "akkoma";
        };
      };
    };
  };

  # Jitsi Meet
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.example.com";
    
    # Konfiguration
    config = {
      enableWelcomePage = true;
      enableInsecureRoomNameWarning = false;
      enableNoisyMicDetection = true;
    };
  };

  # Firewall-Regeln
  networking.firewall = {
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

  # Insecure Pakete erlauben (falls nötig)
  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8043"
  ];

  # Konfigurationsdateien auf ISO inkludieren
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    
    # Konfigurationsdateien für Installation
    (pkgs.writeTextFile {
      name = "akkoma-configs";
      destination = "/etc/nixos-configs/configuration.nix";
      text = builtins.readFile ./configuration.nix;
    })
    (pkgs.writeTextFile {
      name = "akkoma-environment";
      destination = "/etc/nixos-configs/environment.nix";
      text = builtins.readFile ./environment.nix;
    })
    (pkgs.writeTextFile {
      name = "installation-guide";
      destination = "/etc/nixos-configs/README.txt";
      text = ''
        NixOS Akkoma Server Installation
        
        Nach der Installation:
        1. Kopieren Sie die Konfigurationsdateien:
           cp -r /etc/nixos-configs/* /etc/nixos/
        
        2. Bearbeiten Sie /etc/nixos/environment.nix:
           - Ändern Sie die Domain (example.com → Ihre Domain)
           - Ändern Sie die Passwörter
           - Passen Sie die E-Mail-Adresse an
        
        3. Aktivieren Sie die Konfiguration:
           nixos-rebuild switch
        
        4. Starten Sie die Services:
           systemctl start akkoma
           systemctl start jitsi-meet
        
        Services:
        - Akkoma: https://akkoma.ihre-domain.com
        - Jitsi Meet: https://meet.ihre-domain.com
        - PostgreSQL: Port 5432
        - Redis: Port 6379
        
        Dokumentation:
        - Akkoma: https://docs.akkoma.dev/
        - Jitsi: https://jitsi.github.io/handbook/
      '';
    })
  ];
}