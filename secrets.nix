{ lib, config, ... }:
let
  host = config.networking.hostName;

  resolveSecret = name:
    let
      perHost = ./secrets/${host}/${name}.age;
    in
      if builtins.pathExists perHost then perHost else null;

  mkSecret =
    name:
    {
      owner,
      group,
      mode,
    }:
    let
      file = resolveSecret name;
    in
      lib.optionalAttrs (file != null) {
        ${name} = {
          inherit file owner group mode;
        };
      };
in
{
  age.secrets = lib.mkMerge [
    (mkSecret "marcel-password" {
      owner = "root";
      group = "root";
      mode = "0400";
    })
    (mkSecret "hanna-password" {
      owner = "root";
      group = "root";
      mode = "0400";
    })
    (mkSecret "pleroma-secret" {
      owner = "pleroma";
      group = "pleroma";
      mode = "0400";
    })
  ];
}
