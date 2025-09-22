# NixOS Akkoma Server ISO für ARM Mac (Apple Silicon)
# Diese Konfiguration erstellt ein funktionierendes NixOS ISO für ARM64

{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  # System Version
  system.stateVersion = "23.11";

  # ARM-spezifische Einstellungen
  nixpkgs.hostPlatform = "aarch64-linux";

  # Konfigurationsdateien auf ISO inkludieren
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    
    # Konfigurationsdateien für Installation
    (pkgs.writeTextFile {
      name = "akkoma-configs-arm";
      destination = "/etc/nixos-configs/configuration.nix";
      text = builtins.readFile ./configuration.nix;
    })
    (pkgs.writeTextFile {
      name = "akkoma-environment-arm";
      destination = "/etc/nixos-configs/environment.nix";
      text = builtins.readFile ./environment.nix;
    })
    (pkgs.writeTextFile {
      name = "installation-guide-arm";
      destination = "/etc/nixos-configs/README.txt";
      text = ''
        NixOS Akkoma Server Installation (ARM64 / Apple Silicon)
        
        DIESES ISO enthält nur die Konfigurationsdateien!
        Die Services werden NACH der Installation aktiviert.
        
        Nach der NixOS Installation:
        1. Kopieren Sie die Konfigurationsdateien:
           cp -r /etc/nixos-configs/* /etc/nixos/
        
        2. Bearbeiten Sie /etc/nixos/environment.nix:
           - Ändern Sie die Domain (example.com → Ihre Domain)
           - Ändern Sie die Passwörter
           - Passen Sie die E-Mail-Adresse an
        
        3. Aktivieren Sie die vollständige Konfiguration:
           nixos-rebuild switch
        
        Services die aktiviert werden:
        ✅ PostgreSQL Database (akkoma, akkoma_test)
        ✅ Redis Caching (Port 6379)
        ✅ Nginx Web Server
        ✅ Akkoma Fediverse Server
        ✅ Jitsi Meet Video Conferencing
        ✅ Firewall Rules (SSH, HTTP, HTTPS, PostgreSQL, Jitsi)
        
        URLs nach Aktivierung:
        - Akkoma: https://akkoma.ihre-domain.com
        - Jitsi Meet: https://meet.ihre-domain.com
        
        ARM64 / Apple Silicon Optimierungen:
        - Optimiert für ARM64 Architektur
        - Bessere Performance auf Apple Silicon Macs
        - Kompatibel mit Parallels Desktop für Mac
        
        Dokumentation:
        - Akkoma: https://docs.akkoma.dev/
        - Jitsi: https://jitsi.github.io/handbook/
      '';
    })
  ];
}
