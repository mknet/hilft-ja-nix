#!/usr/bin/env bash
# Live-ISO: Bootloader auf bestehender Installation reparieren (ohne Neu-Partitionierung)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DISK="${DISK:-/dev/vda}"
SRC="${SRC:-$REPO_ROOT}"
FLAKE_ATTR="${FLAKE_ATTR:-}"
MNT="/mnt"
NIXOS_DIR="${MNT}/etc/nixos"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Bitte als root ausführen: sudo bash $0" >&2
  exit 1
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

case "$(uname -m)" in
  aarch64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein-aarch64}" ;;
  x86_64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein}" ;;
  *)
    echo "Nicht unterstützte Architektur: $(uname -m)" >&2
    exit 1
    ;;
esac

swapoff "${DISK}3" 2>/dev/null || true
umount "${MNT}/boot" 2>/dev/null || true
umount "$MNT" 2>/dev/null || true

echo "=== Bestehende Installation mounten ==="
mkdir -p "$MNT"
mount "${DISK}2" "$MNT"
mkdir -p "${MNT}/boot"
mount "${DISK}1" "${MNT}/boot"
swapon "${DISK}3" 2>/dev/null || true

echo "=== Flake aktualisieren ==="
mkdir -p "$NIXOS_DIR"
cp -a "${SRC}/." "$NIXOS_DIR/"

echo "=== Bootloader neu installieren ==="
nixos-install --flake "${NIXOS_DIR}#${FLAKE_ATTR}" --no-root-passwd

echo
echo "Fertig. In UTM: ISO-Laufwerk entfernen, dann VM starten."
