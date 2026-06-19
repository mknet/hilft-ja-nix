# Linux-Login-Passwörter (wie milkyway, ohne Samba).
# Mit Agenix-Secrets: secrets/<hostname>/marcel-password.age
# Ohne Secrets: initialPassword-Fallback für frische Test-VMs.
{ config, lib, pkgs, ... }:
let
  syncPassword = user: secretPath: ''
    PW="$(tr -d '\n' < ${secretPath})"
    echo "${user}:$PW" | ${pkgs.shadow}/bin/chpasswd
  '';
in
{
  users.users.marcel = lib.mkMerge [
    (lib.mkIf (!(config.age.secrets ? marcel-password)) {
      initialPassword = "pa$$w0rd";
    })
  ];

  users.users.hanna = lib.mkMerge [
    (lib.mkIf (!(config.age.secrets ? hanna-password)) {
      initialPassword = "pa$$w0rd";
    })
  ];

  system.activationScripts.syncUserPasswords =
    lib.mkIf (config.age.secrets ? marcel-password || config.age.secrets ? hanna-password) {
      text =
        lib.concatStringsSep "\n" (
          lib.optional (config.age.secrets ? marcel-password)
            (syncPassword "marcel" config.age.secrets.marcel-password.path)
          ++ lib.optional (config.age.secrets ? hanna-password)
            (syncPassword "hanna" config.age.secrets.hanna-password.path)
        );
      deps = [
        "users"
        "agenix"
      ];
    };
}
