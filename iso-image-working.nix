{ config, pkgs, ... }:

# Bewährte ISO-Konfiguration basierend auf installation-cd-minimal
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  # ISO Image Einstellungen
  isoImage = {
    isoName = "akkoma-server-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    volumeID = "AKKOMA_SERVER";
    makeEfiBootable = true;
    makeUsbBootable = true;
    includeSystemBuildDependencies = true;
  };

  # Zusätzliche Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];

  # SSH für Remote-Installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;  # Für ISO einfacher
    };
  };

  # Root-Passwort für Installation
  users.users.root.password = "akkoma";

  # System-Version
  system.stateVersion = "23.11";
}
