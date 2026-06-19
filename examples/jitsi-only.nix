# Beispiel: Nur Jitsi Meet Server (ohne Akkoma)
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in

{
  imports = [
    # Rollen importieren
    ../roles/nginx.nix
    ../roles/jitsi.nix
  ];

  # Basis-Konfiguration
  networking = {
    hostName = "jitsi-server";
    domain = env.current.domain;
    fqdn = "jitsi-server.${env.current.domain}";
    useDHCP = true;
    firewall.enable = true;
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # ACME
  security.acme = {
    acceptTerms = true;
    defaults.email = env.current.email;
  };

  # Nur Jitsi aktivieren
  roles.jitsi = {
    enable = true;
    domain = env.current.domain;
    hostname = "meet";
  };

  # System Version
  system.stateVersion = "23.11";
}
