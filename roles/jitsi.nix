# Jitsi Meet Rolle - Video Conferencing Server
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.roles.jitsi;
  env = import ../environment.nix;
in
{
  # Rolle konfigurieren
  options.roles.jitsi = {
    enable = mkEnableOption "Jitsi Meet video conferencing";
    
    domain = mkOption {
      type = types.str;
      default = env.current.domain;
      description = "Domain for Jitsi Meet";
    };
    
    hostname = mkOption {
      type = types.str;
      default = "meet";
      description = "Hostname for Jitsi Meet";
    };
    
    enableWelcomePage = mkOption {
      type = types.bool;
      default = true;
      description = "Enable welcome page";
    };
    
    enableInsecureRoomNameWarning = mkOption {
      type = types.bool;
      default = false;
      description = "Enable insecure room name warning";
    };
    
    enableNoisyMicDetection = mkOption {
      type = types.bool;
      default = true;
      description = "Enable noisy microphone detection";
    };
  };

  # Konfiguration anwenden
  config = mkIf cfg.enable {
    # Nginx für Jitsi (falls nicht bereits aktiviert)
    roles.nginx = {
      enable = true;
      enableACME = true;
      virtualHosts = {
        jitsi = {
          domain = "${cfg.hostname}.${cfg.domain}";
          proxyPass = null;  # Jitsi verwendet eigenen Nginx
          root = null;
        };
      };
    };

    # Jitsi Meet Service
    services.jitsi-meet = {
      enable = true;
      hostName = "${cfg.hostname}.${cfg.domain}";
      
      config = {
        enableWelcomePage = cfg.enableWelcomePage;
        enableInsecureRoomNameWarning = cfg.enableInsecureRoomNameWarning;
        enableNoisyMicDetection = cfg.enableNoisyMicDetection;
      };
    };

    # Firewall-Regeln für Jitsi
    networking.firewall.allowedTCPPorts = [
      5222   # XMPP
      5269   # XMPP
      5280   # XMPP
      5347   # TURN
      10000  # Jitsi Meet
      10001  # Jitsi Meet
    ];
    
    networking.firewall.allowedUDPPorts = [
      10000  # Jitsi Meet
      10001  # Jitsi Meet
    ];

    # Insecure Pakete erlauben (falls nötig)
    nixpkgs.config.permittedInsecurePackages = [
      "jitsi-meet-1.0.8043"
    ];

    # Health Check
    systemd.services.jitsi-health = {
      description = "Jitsi Meet Health Check";
      after = [ "jitsi-meet.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -f https://${cfg.hostname}.${cfg.domain}/ || exit 1";
        RemainAfterExit = true;
      };
    };
  };
}
