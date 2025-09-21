{ config, pkgs, ... }:

# Ultra-minimale ISO - nur NixOS Basis
{
  imports = [
    ./configuration-ultra-minimal.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
  ];

  # ISO Image Einstellungen
  isoImage = {
    isoName = "akkoma-server-ultra-minimal-${config.system.nixos.version}-${pkgs.stdenv.hostPlatform.system}.iso";
    volumeID = "AKKOMA_ULTRA";
    makeEfiBootable = true;
    makeUsbBootable = true;
    includeSystemBuildDependencies = true;
  };

  # Basis-Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    
    (pkgs.writeTextFile {
      name = "akkoma-configs";
      destination = "/etc/nixos-configs/configuration.nix";
      text = builtins.readFile ./configuration-ultra-minimal.nix;
    })
  ];

  # Installation erleichtern
  services.getty.autologinUser = "root";
  users.users.root.password = "akkoma";
  services.openssh.enable = true;
  
  # System-Version
  system.stateVersion = "23.11";
}
