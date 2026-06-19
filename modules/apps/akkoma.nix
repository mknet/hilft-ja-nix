# Akkoma — Fediverse-Server (Elixir, Fork von Pleroma)
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.akkoma;
  env = import ../../environment.nix;
in
{
  options.helferlein.apps.akkoma = {
    enable = lib.mkEnableOption "Akkoma Fediverse server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = env.current.domain;
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "akkoma";
      description = "Subdomain for Akkoma (akkoma.example.com)";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = env.current.email;
    };

    database = lib.mkOption {
      type = lib.types.str;
      default = env.current.database.name;
    };

    databaseUser = lib.mkOption {
      type = lib.types.str;
      default = env.current.database.user;
    };

    secret = lib.mkOption {
      type = lib.types.str;
      default = env.current.akkoma.secret;
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = lib.mkDefault true;
      ensureDatabases = lib.mkAfter [ cfg.database "${cfg.database}_test" ];
      ensureUsers = lib.mkAfter [{
        name = cfg.databaseUser;
        ensureDBOwnership = true;
      }];
    };

    services.redis = {
      enable = lib.mkDefault true;
      servers."" = {
        enable = true;
        bind = "127.0.0.1";
        port = 6379;
      };
    };

    services.nginx = {
      enable = lib.mkDefault true;
      virtualHosts."${cfg.hostname}.${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

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

    networking.firewall.allowedTCPPorts = lib.mkAfter [ cfg.port ];
  };
}
