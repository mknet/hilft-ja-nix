{ config, pkgs, ... }:

# ISO Image Konfiguration
{
  imports = [
    ./configuration.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
  ];

  # ISO Image Einstellungen
  isoImage = {
    isoName = "akkoma-server-${config.system.nixos.version}-${pkgs.stdenv.hostPlatform.system}.iso";
    volumeID = "AKKOMA_SERVER";
    makeEfiBootable = true;
    makeUsbBootable = true;
    includeSystemBuildDependencies = true;
  };

  # Konfigurationsdateien auf ISO inkludieren
  environment.systemPackages = with pkgs; [
    # Basis-Tools
    vim
    git
    curl
    wget
    htop
    tmux
    nano
    
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
           - Ändern Sie die Domain
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

  # Boot-Menü anpassen
  boot.loader.grub.splashImage = null;
  
  # ISO-spezifische Einstellungen
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # Installation erleichtern
  services.getty.autologinUser = "root";
  
  # SSH für Remote-Installation
  services.openssh.enable = true;
  users.users.root.password = "akkoma";  # Temporäres Passwort für Installation
  
  # System-Version
  system.stateVersion = "23.11";
}