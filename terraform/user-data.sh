#!/bin/bash
# User Data Script für NixOS Installation auf Hetzner Cloud
# Dieses Script wird beim ersten Boot des Servers ausgeführt

set -e

echo "🚀 NixOS Akkoma Server Installation auf Hetzner Cloud"
echo "====================================================="

# System aktualisieren
apt update && apt upgrade -y

# Nix installieren
echo "📦 Installiere Nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- --no-confirm

# Nix Environment laden
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# NixOS installieren
echo "🐧 Installiere NixOS..."
nix-env -iA nixpkgs.nixos-install-tools

# Konfigurationsdateien erstellen
echo "📝 Erstelle Konfigurationsdateien..."
mkdir -p /etc/nixos

# configuration.nix
cat > /etc/nixos/configuration.nix << 'EOF'
${configuration_nix}
EOF

# environment.nix
cat > /etc/nixos/environment.nix << 'EOF'
${environment_nix}
EOF

# Hardware-Konfiguration generieren
echo "🔧 Generiere Hardware-Konfiguration..."
nixos-generate-config --root /

# NixOS installieren
echo "⚙️  Installiere NixOS..."
nixos-install --root / --no-root-passwd

echo "✅ NixOS Installation abgeschlossen!"
echo "🔄 Server wird neu gestartet..."

# Server neu starten
reboot
