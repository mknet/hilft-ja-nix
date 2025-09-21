# NixOS Minimal Installation ISO
# Diese Konfiguration erstellt ein funktionierendes NixOS ISO

{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  # ISO-Einstellungen
  isoImage.isoName = "nixos-minimal-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  # System Version
  system.stateVersion = "23.11";
}