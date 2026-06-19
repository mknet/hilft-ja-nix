# Pleroma — Fediverse-Server (wie in helferlein/docker/pleroma)
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.pleroma;
  env = import ../../environment.nix;
  fqdn = "${cfg.hostname}.${cfg.domain}";
  hasAgenixSecret = config.age.secrets ? pleroma-secret;

  pleromaConfig = pkgs.writeText "pleroma-config.exs" ''
    import Config

    config :pleroma, Pleroma.Web.Endpoint,
      url: [host: "${fqdn}", scheme: "https", port: 443],
      http: [ip: {127, 0, 0, 1}, port: ${toString cfg.port}]

    config :pleroma, :instance,
      name: "${cfg.instanceName}",
      email: "${cfg.adminEmail}",
      notify_email: "${cfg.notifyEmail}",
      limit: 100000,
      registrations_open: false,
      federating: true,
      healthcheck: true,
      allow_relay: true,
      public: false

    config :pleroma, Pleroma.Repo,
      adapter: Ecto.Adapters.Postgres,
      username: "${cfg.databaseUser}",
      database: "${cfg.databaseName}",
      socket_dir: "/run/postgresql",
      pool_size: 10

    config :web_push_encryption, :vapid_details,
      subject: "mailto:${cfg.notifyEmail}"

    config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
    config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"
  '';
in
{
  options.helferlein.apps.pleroma = {
    enable = lib.mkEnableOption "Pleroma Fediverse server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = env.current.domain;
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.hostname;
      description = "Subdomain for Pleroma (social.example.com)";
    };

    instanceName = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.instanceName;
    };

    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.adminEmail;
    };

    notifyEmail = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.notifyEmail;
    };

    databaseName = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.databaseName;
    };

    databaseUser = lib.mkOption {
      type = lib.types.str;
      default = env.current.pleroma.databaseUser;
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = lib.mkDefault true;
      ensureDatabases = lib.mkAfter [ cfg.databaseName ];
      ensureUsers = lib.mkAfter [
        {
          name = cfg.databaseUser;
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };

    services.pleroma = {
      enable = true;
      configs = [ (builtins.readFile pleromaConfig) ];
      secretConfigFile =
        if hasAgenixSecret then
          config.age.secrets.pleroma-secret.path
        else
          "/var/lib/pleroma/secret.exs";
    };

    # Fallback ohne agenix (Test-VM): nur Endpoint-Secrets, kein DB-Passwort (Peer-Auth)
    system.activationScripts.pleromaSecret = lib.mkIf (!hasAgenixSecret) {
      deps = [ "users" ];
      text = ''
        install -d -o pleroma -g pleroma -m 700 /var/lib/pleroma
        if [ ! -f /var/lib/pleroma/secret.exs ]; then
          secret_key_base="$(${pkgs.openssl}/bin/openssl rand -hex 64)"
          signing_salt="$(${pkgs.openssl}/bin/openssl rand -hex 16)"
          cat > /var/lib/pleroma/secret.exs <<EOF
        import Config

        config :pleroma, Pleroma.Web.Endpoint,
          secret_key_base: "$secret_key_base",
          signing_salt: "$signing_salt"

        config :web_push_encryption, :vapid_details,
          public_key: "$(${pkgs.openssl}/bin/openssl rand -base64 65 | tr -d '\n=')",
          private_key: "$(${pkgs.openssl}/bin/openssl rand -base64 32 | tr -d '\n=')"
        EOF
          chown pleroma:pleroma /var/lib/pleroma/secret.exs
          chmod 600 /var/lib/pleroma/secret.exs
        fi
      '';
    };

    # Pleroma-Migrationen brauchen citext/pg_trgm — einmalig als postgres
    systemd.services.pleroma-postgres-extensions = {
      description = "Pleroma PostgreSQL extensions";
      before = [ "pleroma-migrations.service" ];
      after = [
        "postgresql.service"
        "postgresql-setup.service"
      ];
      requires = [
        "postgresql.service"
        "postgresql-setup.service"
      ];
      wantedBy = [ "pleroma-migrations.service" ];
      path = [ config.services.postgresql.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
      };
      script = ''
        psql -v ON_ERROR_STOP=1 -d ${lib.escapeShellArg cfg.databaseName} -c 'CREATE EXTENSION IF NOT EXISTS citext;'
        psql -v ON_ERROR_STOP=1 -d ${lib.escapeShellArg cfg.databaseName} -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
      '';
    };

    systemd.services.pleroma = {
      after = lib.mkAfter [
        "postgresql.service"
        "postgresql-setup.service"
      ];
      requires = lib.mkAfter [
        "postgresql.service"
        "postgresql-setup.service"
      ];
      serviceConfig.BindReadOnlyPaths = lib.mkAfter [
        "/run/postgresql:/run/postgresql:norbind"
      ];
    };

    systemd.services.pleroma-migrations = {
      after = lib.mkAfter [
        "postgresql.service"
        "postgresql-setup.service"
        "pleroma-postgres-extensions.service"
      ];
      requires = lib.mkAfter [
        "postgresql.service"
        "postgresql-setup.service"
        "pleroma-postgres-extensions.service"
      ];
      serviceConfig.BindReadOnlyPaths = lib.mkAfter [
        "/run/postgresql:/run/postgresql:norbind"
      ];
    };

    services.nginx = {
      enable = lib.mkDefault true;
      virtualHosts.${fqdn} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkAfter [ cfg.port ];
  };
}
