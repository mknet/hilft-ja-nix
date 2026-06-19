#!/usr/bin/env bash
# Dev-Checkout (~/nix) nach /etc/nixos deployen und switch ausführen
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NIXOS_DIR="/etc/nixos"
FLAKE_ATTR="${FLAKE_ATTR:-}"

case "$(uname -m)" in
  aarch64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein-aarch64}" ;;
  x86_64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein}" ;;
  *)
    echo "Nicht unterstützte Architektur: $(uname -m)" >&2
    exit 1
    ;;
esac

echo "=== Deploy ${REPO_ROOT} → ${NIXOS_DIR} ==="
sudo rsync -a --delete \
  --exclude='.git' \
  --exclude='hardware-configuration.nix' \
  "${REPO_ROOT}/" "${NIXOS_DIR}/"

echo "=== nixos-rebuild switch ==="
exec sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
