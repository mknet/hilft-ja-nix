# Beispiel: Nur Jitsi Meet
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in
{
  imports = [ ../modules ];

  networking = {
    hostName = "jitsi-server";
    domain = env.current.domain;
    useDHCP = true;
    firewall.enable = true;
  };

  services.openssh.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = env.current.email;
  };

  helferlein.apps.jitsi.enable = true;

  system.stateVersion = "26.05";
}
