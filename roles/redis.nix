# Redis Rolle - Wiederverwendbare Redis-Konfiguration
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.roles.redis;
in
{
  # Rolle konfigurieren
  options.roles.redis = {
    enable = mkEnableOption "Redis cache server";
    
    port = mkOption {
      type = types.port;
      default = 6379;
      description = "Redis port";
    };
    
    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Redis bind address";
    };
    
    password = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Redis password (null for no password)";
    };
    
    maxmemory = mkOption {
      type = types.nullOr types.str;
      default = "256mb";
      description = "Maximum memory usage";
    };
  };

  # Konfiguration anwenden
  config = mkIf cfg.enable {
    # Redis Service
    services.redis = {
      enable = true;
      servers."" = {
        enable = true;
        port = cfg.port;
        bind = cfg.bind;
        password = cfg.password;
        maxmemory = cfg.maxmemory;
      };
    };

    # Firewall-Regel für Redis
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Health Check
    systemd.services.redis-health = {
      description = "Redis Health Check";
      after = [ "redis.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.redis}/bin/redis-cli -h ${cfg.bind} -p ${toString cfg.port} ping";
        RemainAfterExit = true;
      };
    };
  };
}
