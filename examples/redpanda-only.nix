# Beispiel: Redpanda (wie helferlein/docker/redpanda)
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in
{
  imports = [ ../modules ];

  networking = {
    hostName = "redpanda-server";
    domain = env.current.domain;
    useDHCP = true;
    firewall.enable = true;
  };

  services.openssh.enable = true;

  helferlein.apps.redpanda.enable = true;

  system.stateVersion = "26.05";
}
