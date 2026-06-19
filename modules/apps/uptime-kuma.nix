# Uptime Kuma — Status-Monitoring (wie in helferlein/docker/uptime-kuma)
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.uptime-kuma;
  env = import ../../environment.nix;
in
{
  options.helferlein.apps.uptime-kuma = {
    enable = lib.mkEnableOption "Uptime Kuma monitoring dashboard";

    domain = lib.mkOption {
      type = lib.types.str;
      default = env.current.uptimeKuma.domain;
      description = "Public hostname (uptime.example.com)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "127.0.0.1";
        PORT = toString cfg.port;
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
