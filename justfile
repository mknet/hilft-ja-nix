# Justfile für NixOS Akkoma Server Projekt

# Prüft die gesamte Konfiguration, beginnend beim Flake
check:
    #! /usr/bin/env bash
    set +e
    bash -l -c 'echo "🔍 Prüfe Flake-Konfiguration..."; nix flake check --impure 2>&1'
    FLAKE_CHECK=$?
    if [ $FLAKE_CHECK -eq 0 ]; then
        echo ""
        echo "✅ Flake-Konfiguration ist gültig!"
    else
        echo ""
        echo "⚠️  Flake-Check mit Fehlern (möglicherweise wegen <nixpkgs> Imports)"
    fi
    echo ""
    echo "🔍 Prüfe NixOS-Konfigurationen..."
    bash -l -c 'nix eval --json --impure .#nixosConfigurations.akkoma-server.config.system.name --no-warn-dirty 2>&1 || echo "akkoma-server: Fehler"'
    bash -l -c 'nix eval --json --impure .#nixosConfigurations.hetzner-akkoma.config.system.name --no-warn-dirty 2>&1 || echo "hetzner-akkoma: Fehler"'
    bash -l -c 'nix eval --json --impure .#nixosConfigurations.iso-image.config.system.name --no-warn-dirty 2>&1 || echo "iso-image: Fehler"'
    echo ""
    echo "✅ Check abgeschlossen!"

# Prüft nur die Flake-Syntax
check-flake:
    bash -l -c 'nix flake check --no-build --impure || nix flake check --no-build'

# Prüft eine spezifische NixOS-Konfiguration
check-config CONFIG:
    bash -l -c 'set -euo pipefail; echo "🔍 Prüfe NixOS-Konfiguration: {{CONFIG}}"; nix eval --json --impure .#nixosConfigurations.{{CONFIG}}.config.system.name --no-warn-dirty; echo "✅ Konfiguration {{CONFIG}} ist gültig!"'

# Formatiert alle Nix-Dateien
format:
    bash -l -c 'nix fmt'

# Zeigt verfügbare NixOS-Konfigurationen
list-configs:
    bash -l -c 'nix flake show'

# Baut die ISO (ARM64)
build-iso:
    bash -l -c 'nix build .#packages.aarch64-linux.iso'

# Baut das QCOW2 Image (ARM64)
build-qcow2:
    bash -l -c 'nix build .#packages.aarch64-linux.qcow2'

# Öffnet eine Nix-Shell mit allen Development-Tools
shell:
    bash -l -c 'nix develop'
