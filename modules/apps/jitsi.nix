# Jitsi Meet — Videokonferenzen
{ config, pkgs, lib, ... }:

let
  cfg = config.helferlein.apps.jitsi;
  env = import ../../environment.nix;
  fqdn = "${cfg.hostname}.${cfg.domain}";
in
{
  options.helferlein.apps.jitsi = {
    enable = lib.mkEnableOption "Jitsi Meet video conferencing";

    domain = lib.mkOption {
      type = lib.types.str;
      default = env.current.domain;
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = env.current.jitsi.hostname;
      description = "Subdomain for Jitsi (meet.example.com)";
    };

    enableWelcomePage = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enableInsecureRoomNameWarning = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    enableNoisyMicDetection = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.enable = lib.mkDefault true;

    services.jitsi-meet = {
      enable = true;
      hostName = fqdn;
      config = {
        enableWelcomePage = cfg.enableWelcomePage;
        enableInsecureRoomNameWarning = cfg.enableInsecureRoomNameWarning;
        enableNoisyMicDetection = cfg.enableNoisyMicDetection;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkAfter [
      5222 5269 5280 5347 10000 10001
    ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ 10000 10001 ];

    nixpkgs.config.permittedInsecurePackages = lib.mkAfter [
      "jitsi-meet-1.0.8043"
    ];
  };
}
