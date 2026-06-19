{
  description = "NixOS Helferlein Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    age-encryption.url = "github:ryantm/agenix/main";
    age-encryption.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, age-encryption, ... }@inputs:
    let
      mkHost = system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [ ./hosts/helferlein.nix ];
      };

      nixosConfigurations = {
        helferlein = mkHost "x86_64-linux";
        helferlein-aarch64 = mkHost "aarch64-linux";
      };

      isoConfiguration = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./iso-image.nix ];
      };

      iso = isoConfiguration.config.system.build.isoImage;
    in
    {
      inherit nixosConfigurations;

      nixosModules.default = ./modules;
    } // flake-utils.lib.eachDefaultSystem (hostSystem:
      let
        pkgs = import nixpkgs {
          system = hostSystem;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          inherit iso;
          default = iso;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            nixpkgs-fmt
          ];

          shellHook = ''
            echo "Helferlein NixOS"
            echo "  just check      — Konfiguration prüfen"
            echo "  just build-iso  — x86_64 ISO bauen"
          '';
        };
      }
    );
}
