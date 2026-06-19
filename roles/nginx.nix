# Nginx Rolle - Wiederverwendbare Nginx-Konfiguration
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.roles.nginx;
in
{
  # Rolle konfigurieren
  options.roles.nginx = {
    enable = mkEnableOption "Nginx web server";
    
    enableACME = mkEnableOption "Enable ACME (Let's Encrypt)";
    
    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          domain = mkOption {
            type = types.str;
            description = "Domain name";
          };
          proxyPass = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Proxy pass URL";
          };
          root = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Document root";
          };
          forceSSL = mkOption {
            type = types.bool;
            default = true;
            description = "Force SSL redirect";
          };
        };
      });
      default = { };
      description = "Virtual hosts configuration";
    };
    
    ports = mkOption {
      type = types.listOf types.port;
      default = [ 80 443 ];
      description = "Ports to open in firewall";
    };
  };

  # Konfiguration anwenden
  config = mkIf cfg.enable {
    # Nginx Service
    services.nginx = {
      enable = true;
      enableACME = cfg.enableACME;
      
      # Virtual Hosts
      virtualHosts = lib.mapAttrs (name: host: {
        ${host.domain} = {
          forceSSL = host.forceSSL;
          enableACME = cfg.enableACME;
          locations."/" = if host.proxyPass != null then {
            proxyPass = host.proxyPass;
            proxyWebsockets = true;
          } else {
            root = host.root;
            index = "index.html";
          };
        };
      }) cfg.virtualHosts;
    };

    # Firewall-Regeln für Nginx
    networking.firewall.allowedTCPPorts = cfg.ports;

    # Health Check
    systemd.services.nginx-health = {
      description = "Nginx Health Check";
      after = [ "nginx.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -f http://localhost/ || exit 1";
        RemainAfterExit = true;
      };
    };
  };
}
