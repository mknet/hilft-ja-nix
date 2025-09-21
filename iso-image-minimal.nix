{ config, pkgs, ... }:

# Minimale ISO für ersten Test
{
  imports = [
    ./configuration-minimal.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
  ];

  # ISO Image Einstellungen
  isoImage = {
    isoName = "akkoma-server-minimal-${config.system.nixos.version}-${pkgs.stdenv.hostPlatform.system}.iso";
    volumeID = "AKKOMA_MINIMAL";
    makeEfiBootable = true;
    makeUsbBootable = true;
    includeSystemBuildDependencies = true;
  };

  # Konfigurationsdateien auf ISO
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    
    (pkgs.writeTextFile {
      name = "akkoma-configs";
      destination = "/etc/nixos-configs/configuration.nix";
      text = builtins.readFile ./configuration-minimal.nix;
    })
    (pkgs.writeTextFile {
      name = "akkoma-environment";
      destination = "/etc/nixos-configs/environment.nix";
      text = builtins.readFile ./environment.nix;
    })
  ];

  # Installation erleichtern
  services.getty.autologinUser = "root";
  users.users.root.password = "akkoma";
  services.openssh.enable = true;
  
  # System-Version
  system.stateVersion = "23.11";
}
