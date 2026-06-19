# Akkoma Rolle - Fediverse Server mit Abhängigkeiten
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.roles.akkoma;
  env = import ../environment.nix;
in
{
  # Rolle konfigurieren
  options.roles.akkoma = {
    enable = mkEnableOption "Akkoma Fediverse server";
    
    domain = mkOption {
      type = types.str;
      default = env.current.domain;
      description = "Domain for Akkoma";
    };
    
    hostname = mkOption {
      type = types.str;
      default = env.current.hostname;
      description = "Hostname for Akkoma";
    };
    
    email = mkOption {
      type = types.str;
      default = env.current.email;
      description = "Admin email";
    };
    
    database = mkOption {
      type = types.str;
      default = env.current.database.name;
      description = "Database name";
    };
    
    databaseUser = mkOption {
      type = types.str;
      default = env.current.database.user;
      description = "Database user";
    };
    
    secret = mkOption {
      type = types.str;
      default = env.current.akkoma.secret;
      description = "Akkoma secret key";
    };
    
    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Akkoma port";
    };
  };

  # Konfiguration anwenden
  config = mkIf cfg.enable {
    # Abhängigkeiten aktivieren
    roles.postgresql = {
      enable = true;
      databases = [ cfg.database "${cfg.database}_test" ];
      users = [{
        name = cfg.databaseUser;
        databases = [ cfg.database "${cfg.database}_test" ];
      }];
    };
    
    roles.redis = {
      enable = true;
      port = 6379;
    };
    
    roles.nginx = {
      enable = true;
      enableACME = true;
      virtualHosts = {
        akkoma = {
          domain = "${cfg.hostname}.${cfg.domain}";
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };

    # Akkoma Service
    services.akkoma = {
      enable = true;
      initSecrets = [ cfg.secret ];
      config = {
        ":pleroma" = {
          ":instance" = {
            name = "Akkoma Server";
            email = cfg.email;
            description = "Akkoma instance running on NixOS";
          };
          ":database" = {
            hostname = "localhost";
            database = cfg.database;
            username = cfg.databaseUser;
          };
        };
      };
    };

    # Firewall-Regel für Akkoma
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Health Check
    systemd.services.akkoma-health = {
      description = "Akkoma Health Check";
      after = [ "akkoma.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -f http://localhost:${toString cfg.port}/api/v1/instance || exit 1";
        RemainAfterExit = true;
      };
    };
  };
}
