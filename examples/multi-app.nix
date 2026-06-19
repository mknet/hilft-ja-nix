# Beispiel: Vollständiger Stack — alle Apps
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in
{
  imports = [ ../modules ];

  networking = {
    hostName = "multi-app-server";
    domain = env.current.domain;
    useDHCP = true;
    firewall.enable = true;
  };

  services.openssh.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = env.current.email;
  };

  services.fail2ban.enable = true;
  virtualisation.docker.enable = true;

  # Helferlein-Stack + Jitsi + Redpanda
  # Hinweis: Akkoma und Pleroma sind Fediverse-Alternativen — nur eines aktivieren
  helferlein.apps.jitsi.enable = true;
  helferlein.apps.keycloak.enable = true;
  helferlein.apps.uptime-kuma.enable = true;
  helferlein.apps.pleroma.enable = true;
  helferlein.apps.redpanda.enable = true;

  system.stateVersion = "26.05";
}
