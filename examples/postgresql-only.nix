# Beispiel: Nur PostgreSQL Server (für andere Anwendungen)
{ config, pkgs, lib, ... }:

let
  env = import ../environment.nix;
in

{
  imports = [
    # Rollen importieren
    ../roles/postgresql.nix
  ];

  # Basis-Konfiguration
  networking = {
    hostName = "postgresql-server";
    domain = env.current.domain;
    fqdn = "postgresql-server.${env.current.domain}";
    useDHCP = true;
    firewall.enable = true;
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Nur PostgreSQL aktivieren
  roles.postgresql = {
    enable = true;
    databases = [ "app1" "app2" "app3" ];
    users = [
      {
        name = "app1_user";
        databases = [ "app1" ];
      }
      {
        name = "app2_user";
        databases = [ "app2" ];
      }
      {
        name = "app3_user";
        databases = [ "app3" ];
      }
    ];
    port = 5432;
    version = "15";
  };

  # System Version
  system.stateVersion = "23.11";
}
