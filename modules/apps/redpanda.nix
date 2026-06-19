# Redpanda — Kafka-kompatibles Streaming (wie in helferlein/docker/redpanda)
#
# Kein natives NixOS-Modul — läuft via OCI-Container.
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.redpanda;
  env = import ../../environment.nix;
in
{
  options.helferlein.apps.redpanda = {
    enable = lib.mkEnableOption "Redpanda streaming platform with web console";

    enableConsole = lib.mkOption {
      type = lib.types.bool;
      default = env.current.redpanda.enableConsole;
      description = "Enable Redpanda Console web UI";
    };

    kafkaPort = lib.mkOption {
      type = lib.types.port;
      default = 19092;
    };

    schemaRegistryPort = lib.mkOption {
      type = lib.types.port;
      default = 18081;
    };

    pandaproxyPort = lib.mkOption {
      type = lib.types.port;
      default = 18082;
    };

    adminPort = lib.mkOption {
      type = lib.types.port;
      default = 19644;
    };

    consolePort = lib.mkOption {
      type = lib.types.port;
      default = 8888;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      containers.redpanda = {
        image = "docker.redpanda.com/redpandadata/redpanda:v23.3.1";
        cmd = [
          "redpanda" "start"
          "--kafka-addr" "internal://0.0.0.0:9092,external://0.0.0.0:${toString cfg.kafkaPort}"
          "--advertise-kafka-addr" "internal://redpanda:9092,external://localhost:${toString cfg.kafkaPort}"
          "--pandaproxy-addr" "internal://0.0.0.0:8082,external://0.0.0.0:${toString cfg.pandaproxyPort}"
          "--advertise-pandaproxy-addr" "internal://redpanda:8082,external://localhost:${toString cfg.pandaproxyPort}"
          "--schema-registry-addr" "internal://0.0.0.0:8081,external://0.0.0.0:${toString cfg.schemaRegistryPort}"
          "--rpc-addr" "redpanda:33145"
          "--advertise-rpc-addr" "redpanda:33145"
          "--smp" "1"
          "--memory" "450M"
          "--mode" "dev-container"
        ];
        ports = [
          "${toString cfg.schemaRegistryPort}:8081"
          "${toString cfg.pandaproxyPort}:8082"
          "${toString cfg.kafkaPort}:9092"
          "${toString cfg.adminPort}:9644"
        ];
        volumes = [
          "/var/lib/redpanda:/var/lib/redpanda/data"
        ];
      };

      containers.redpanda-console = lib.mkIf cfg.enableConsole {
        image = "docker.redpanda.com/redpandadata/console:v2.3.8";
        dependsOn = [ "redpanda" ];
        ports = [ "${toString cfg.consolePort}:8080" ];
        environment = {
          CONFIG_FILEPATH = "/tmp/config.yml";
          CONSOLE_CONFIG_FILE = ''
            kafka:
              brokers: ["redpanda:9092"]
              schemaRegistry:
                enabled: true
                urls: ["http://redpanda:8081"]
            redpanda:
              adminApi:
                enabled: true
                urls: ["http://redpanda:9644"]
          '';
        };
        cmd = [
          "/bin/sh" "-c"
          "echo \"$CONSOLE_CONFIG_FILE\" > /tmp/config.yml && /app/console"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkAfter (
      [ cfg.kafkaPort cfg.schemaRegistryPort cfg.pandaproxyPort cfg.adminPort ]
      ++ lib.optional cfg.enableConsole cfg.consolePort
    );
  };
}
