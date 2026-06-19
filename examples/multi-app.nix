# Beispiel: Mehrere Anwendungen mit geteilter PostgreSQL-Instanz
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
    ../roles/jitsi.nix
  ];

  # Basis-Konfiguration
  networking = {
    hostName = "multi-app-server";
    domain = env.current.domain;
    fqdn = "multi-app-server.${env.current.domain}";
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

  # Geteilte PostgreSQL-Instanz für alle Anwendungen
  roles.postgresql = {
    enable = true;
    databases = [
      "akkoma"
      "akkoma_test"
      "jitsi"
      "jitsi_test"
      "app3"
      "app3_test"
    ];
    users = [
      {
        name = "akkoma_user";
        databases = [ "akkoma" "akkoma_test" ];
      }
      {
        name = "jitsi_user";
        databases = [ "jitsi" "jitsi_test" ];
      }
      {
        name = "app3_user";
        databases = [ "app3" "app3_test" ];
      }
    ];
    port = 5432;
    version = "15";
  };

  # Redis für Caching
  roles.redis = {
    enable = true;
    port = 6379;
    maxmemory = "512mb";
  };

  # Nginx für alle Anwendungen
  roles.nginx = {
    enable = true;
    enableACME = true;
    virtualHosts = {
      localhost = {
        domain = "localhost";
        root = "/var/www/html";
        proxyPass = null;
      };
    };
  };

  # Akkoma (nutzt geteilte PostgreSQL)
  roles.akkoma = {
    enable = true;
    domain = env.current.domain;
    hostname = "akkoma";
    email = env.current.email;
    database = "akkoma";
    databaseUser = "akkoma_user";
    secret = env.current.akkoma.secret;
  };

  # Jitsi (nutzt geteilte PostgreSQL)
  roles.jitsi = {
    enable = true;
    domain = env.current.domain;
    hostname = "meet";
  };

  # System Version
  system.stateVersion = "23.11";
}
