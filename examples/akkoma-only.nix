# Beispiel: Nur Akkoma Server (ohne Jitsi)
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in

{
  imports = [
    # Rollen importieren
    ../roles/postgresql.nix
    ../roles/redis.nix
    ../roles/nginx.nix
    ../roles/akkoma.nix
  ];

  # Basis-Konfiguration
  networking = {
    hostName = "akkoma-server";
    domain = env.current.domain;
    fqdn = "akkoma-server.${env.current.domain}";
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

  # Nur Akkoma aktivieren (PostgreSQL und Redis werden automatisch aktiviert)
  roles.akkoma = {
    enable = true;
    domain = env.current.domain;
    hostname = "akkoma-server";
    email = env.current.email;
    database = env.current.database.name;
    databaseUser = env.current.database.user;
    secret = env.current.akkoma.secret;
  };

  # System Version
  system.stateVersion = "23.11";
}
