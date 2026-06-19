# x86_64 Installations-ISO für Helferlein
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  system.stateVersion = "26.05";

  image.fileName = lib.mkForce "nixos-helferlein-${config.system.nixos.version}-x86_64-linux.iso";

  isoImage.volumeID = lib.mkForce "NIXOS_HELFERLEIN";

  environment.systemPackages = with pkgs; [
    vim git curl wget htop
  ];

  environment.etc = {
    "nixos-configs/flake.nix".source = ./flake.nix;
    "nixos-configs/flake.lock".source = ./flake.lock;
    "nixos-configs/environment.nix".source = ./environment.nix;
    "nixos-configs/passwords.nix".source = ./passwords.nix;
    "nixos-configs/secrets.nix".source = ./secrets.nix;
    "nixos-configs/hosts/helferlein.nix".source = ./hosts/helferlein.nix;
    "nixos-configs/modules/default.nix".source = ./modules/default.nix;
    "nixos-configs/modules/apps/akkoma.nix".source = ./modules/apps/akkoma.nix;
    "nixos-configs/modules/apps/jitsi.nix".source = ./modules/apps/jitsi.nix;
    "nixos-configs/modules/apps/keycloak.nix".source = ./modules/apps/keycloak.nix;
    "nixos-configs/modules/apps/uptime-kuma.nix".source = ./modules/apps/uptime-kuma.nix;
    "nixos-configs/modules/apps/pleroma.nix".source = ./modules/apps/pleroma.nix;
    "nixos-configs/modules/apps/redpanda.nix".source = ./modules/apps/redpanda.nix;
    "nixos-configs/README.txt".text = ''
      Helferlein NixOS Installation

      Live-ISO → Festplatte (nixos-install), danach erst nixos-rebuild switch.

      1. Partitionieren und mounten (lsblk — Geräte anpassen):
         sudo mount /dev/disk/by-label/nixos /mnt
         sudo mkdir -p /mnt/boot && sudo mount /dev/disk/by-label/boot /mnt/boot
         sudo swapon /dev/disk/by-label/swap

      2. Konfiguration kopieren:
         sudo mkdir -p /mnt/etc/nixos
         sudo cp -r /etc/nixos-configs/. /mnt/etc/nixos/

      3. Hardware-Konfiguration für die Ziel-Festplatte erzeugen:
         sudo nixos-generate-config --root /mnt

      4. environment.nix anpassen (Domain, Passwörter, E-Mail)

      5. Installation (Architektur wählen):
         sudo nixos-install --flake /mnt/etc/nixos#helferlein --no-root-passwd
         # Apple Silicon / aarch64 VM:
         sudo nixos-install --flake /mnt/etc/nixos#helferlein-aarch64 --no-root-passwd

      6. Reboot, dann Updates:
         sudo nixos-rebuild switch --flake /etc/nixos#helferlein

      Services: Keycloak, Uptime Kuma, Pleroma
    '';
  };
}
