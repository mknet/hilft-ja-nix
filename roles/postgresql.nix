# PostgreSQL Rolle - Wiederverwendbare PostgreSQL-Konfiguration
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.roles.postgresql;
in
{
  # Rolle konfigurieren
  options.roles.postgresql = {
    enable = mkEnableOption "PostgreSQL database server";
    
    databases = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of databases to create";
    };
    
    users = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Username";
          };
          databases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Databases this user owns";
          };
        };
      });
      default = [ ];
      description = "List of users to create";
    };
    
    port = mkOption {
      type = types.port;
      default = 5432;
      description = "PostgreSQL port";
    };
    
    version = mkOption {
      type = types.str;
      default = "15";
      description = "PostgreSQL version";
    };
  };

  # Konfiguration anwenden
  config = mkIf cfg.enable {
    # PostgreSQL Service
    services.postgresql = {
      enable = true;
      package = pkgs."postgresql_${cfg.version}";
      port = cfg.port;
      
      # Datenbanken erstellen
      ensureDatabases = cfg.databases;
      
      # Benutzer erstellen
      ensureUsers = map (user: {
        name = user.name;
        ensureDBOwnership = true;
      }) cfg.users;
    };

    # Firewall-Regel für PostgreSQL
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Health Check
    systemd.services.postgresql-health = {
      description = "PostgreSQL Health Check";
      after = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.postgresql}/bin/psql -h localhost -p ${toString cfg.port} -U postgres -c 'SELECT 1;'";
        RemainAfterExit = true;
      };
    };
  };
}
