# Keycloak — Identity & Access Management (wie in helferlein/docker/keycloak)
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.keycloak;
  env = import ../../environment.nix;
in
{
  options.helferlein.apps.keycloak = {
    enable = lib.mkEnableOption "Keycloak identity and access management";

    domain = lib.mkOption {
      type = lib.types.str;
      default = env.current.keycloak.domain;
      description = "Public hostname (idm.example.com)";
    };

    adminPassword = lib.mkOption {
      type = lib.types.str;
      default = env.current.keycloak.adminPassword;
    };

    databasePassword = lib.mkOption {
      type = lib.types.str;
      default = env.current.keycloak.databasePassword;
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql.enable = lib.mkDefault true;

    services.keycloak = {
      enable = true;
      initialAdminPassword = cfg.adminPassword;
      settings = {
        hostname = cfg.domain;
        http-port = cfg.port;
        proxy-headers = "xforwarded";
        http-enabled = true;
      };
      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = toString (pkgs.writeText "keycloak-db-password" cfg.databasePassword);
      };
    };

    services.nginx = {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}/";
          proxyWebsockets = true;
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkAfter [ cfg.port ];
  };
}
