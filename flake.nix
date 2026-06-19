# Nix Flake für NixOS Akkoma Server
{
  description = "NixOS Akkoma Server mit Jitsi Meet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # NixOS Konfigurationen (außerhalb von eachDefaultSystem, da system-spezifisch)
      nixosConfigurations = {
        # Lokale Entwicklung (ARM64)
        akkoma-server = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./configuration.nix
          ];
        };

        # Hetzner Cloud Deployment
        hetzner-akkoma = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            {
              # Hetzner-spezifische Anpassungen
              networking.hostName = nixpkgs.lib.mkForce "hetzner-akkoma";
              services.openssh.settings.PermitRootLogin = "yes";
            }
          ];
        };

        # ISO Image (ARM64)
        iso-image = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./iso-image-arm.nix
          ];
        };
      };
    in
    {
      inherit nixosConfigurations;
      
      # Packages für aarch64-linux (unabhängig vom Host-System)
      packages.aarch64-linux = {
        # ISO Image bauen (ARM64)
        iso = nixosConfigurations.iso-image.config.system.build.isoImage;
        
        # QCOW2 Image bauen (ARM64)
        qcow2 = nixosConfigurations.akkoma-server.config.system.build.qcow2Image;
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        # Packages für das Host-System (falls verfügbar)
        packages = {
          # ISO Image bauen (Cross-Compilation von macOS zu Linux)
          iso = nixosConfigurations.iso-image.config.system.build.isoImage;
          
          # QCOW2 Image bauen
          qcow2 = nixosConfigurations.akkoma-server.config.system.build.qcow2Image;
        };

        # Development Shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Cloud Tools
            hcloud
            doctl
            terraform
            
            # Nix Tools
            nix
            nixpkgs-fmt
          ] ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
            # NixOS Tools (nur auf Linux verfügbar)
            nixos-install-tools
            
            # Deployment Tools
            nixos-anywhere
          ];
          
          shellHook = ''
            echo "🚀 NixOS Akkoma Server Development Environment"
            echo "============================================="
            echo "Available commands:"
            echo "  nix build .#packages.aarch64-linux.iso  - Build ARM64 ISO (benötigt Remote Builder)"
            echo "  nix build --system aarch64-linux .#iso  - Build ARM64 ISO (mit Cross-Compilation)"
            echo "  nix build .#qcow2                       - Build QCOW2 image"
            echo ""
            echo "⚠️  Hinweis: ARM64 ISO benötigt Linux-System oder Remote Builder"
            echo "   Optionen:"
            echo "   1. Remote Builder einrichten (siehe README)"
            echo "   2. Auf Linux-System bauen"
            echo ""
          '';
        };
      }
    );
}
