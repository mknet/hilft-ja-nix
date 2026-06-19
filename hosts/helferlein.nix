# Helferlein — VPS (x86_64) oder Test-VM (aarch64)
{ pkgs, lib, age-encryption, ... }:

let
  env = import ../environment.nix;
  hwConfigs = lib.filter builtins.pathExists [
    ../hardware-configuration.nix # nixos-install: file lives next to the flake in /mnt/etc/nixos
    /etc/nixos/hardware-configuration.nix # nixos-rebuild: installed system
  ];
in
{
  imports = [
    ../modules
    ../secrets.nix
    ../passwords.nix
    age-encryption.nixosModules.age
  ] ++ hwConfigs;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Berlin";

  # aarch64 UEFI (UTM): systemd-boot + kein NVRAM
  # x86_64 VPS (Hetzner): GRUB auf /dev/sda
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;

  boot.loader.systemd-boot.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isAarch64;

  boot.loader.grub = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
    enable = lib.mkDefault true;
    device = lib.mkDefault "/dev/sda";
  };

  networking = {
    hostName = env.current.hostname;
    domain = env.current.domain;
    fqdn = "${env.current.hostname}.${env.current.domain}";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim git curl wget htop
  ];

  users.users.marcel = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+iEcbuDZzvxxW4NeXiWqXaUkilfXhq3+ahUnoaMes marcel@MKMacBook2021"
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  users.users.hanna = {
    isNormalUser = true;
  };

  services.openssh.enable = true;

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = env.current.email;
  };

  services.fail2ban.enable = true;
  virtualisation.docker.enable = true;

  helferlein.apps.keycloak.enable = true;
  helferlein.apps.uptime-kuma.enable = true;
  helferlein.apps.pleroma.enable = true;

  system.stateVersion = "26.05";
}
