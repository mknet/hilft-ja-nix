#!/usr/bin/env bash
# NixOS-Installation von der Live-ISO auf die Festplatte.
#
# Voraussetzungen:
#   - VM-Disk mindestens 8 GiB (empfohlen 16 GiB mit Keycloak/Pleroma)
#   - Flake liegt in ~/nix (vom Entwicklungsrechner per rsync)
#
# Aufruf (von überall im Repo):
#   sudo bash ~/nix/scripts/install.sh
#   sudo reboot
#
# Optional:
#   DISK=/dev/vda  SRC=/pfad/zur/flake  FLAKE_ATTR=helferlein-aarch64
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

if [[ ! -b "$DISK" ]]; then
  echo "Block-Device nicht gefunden: $DISK" >&2
  lsblk >&2
  exit 1
fi

if [[ ! -d "$SRC" ]] || [[ ! -f "${SRC}/flake.nix" ]]; then
  echo "Flake nicht gefunden in ${SRC}" >&2
  exit 1
fi

case "$(uname -m)" in
  aarch64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein-aarch64}" ;;
  x86_64) FLAKE_ATTR="${FLAKE_ATTR:-helferlein}" ;;
  *)
    echo "Nicht unterstützte Architektur: $(uname -m)" >&2
    exit 1
    ;;
esac

size_gib=$(( $(blockdev --getsize64 "$DISK") / 1024 / 1024 / 1024 ))
echo "Disk: $DISK (${size_gib} GiB), Flake: #${FLAKE_ATTR}"
lsblk "$DISK"

if (( size_gib < 8 )); then
  echo "Fehler: ${size_gib} GiB reicht nicht — mindestens 8 GiB nötig (empfohlen 16 GiB)." >&2
  exit 1
fi

if (( size_gib < 16 )); then
  echo "Hinweis: ${size_gib} GiB ist knapp; 16 GiB sind angenehmer für Keycloak + Pleroma." >&2
fi

echo "=== Partitionieren ==="
swapoff "${DISK}3" 2>/dev/null || true
umount "${MNT}/boot" 2>/dev/null || true
umount "$MNT" 2>/dev/null || true

wipefs -a "$DISK"
parted "$DISK" --script mklabel gpt
parted "$DISK" --script mkpart ESP fat32 1MiB 256MiB
parted "$DISK" --script set 1 esp on

if (( size_gib >= 12 )); then
  disk_mib=$(( $(blockdev --getsize64 "$DISK") / 1024 / 1024 ))
  swap_mib=2048
  root_end_mib=$(( disk_mib - swap_mib ))
  parted "$DISK" --script mkpart primary ext4 256MiB "${root_end_mib}MiB"
  parted "$DISK" --script mkpart primary linux-swap "${root_end_mib}MiB" 100%
else
  parted "$DISK" --script mkpart primary ext4 256MiB 100%
fi

mkfs.fat -F 32 -n boot "${DISK}1"
mkfs.ext4 -F -L nixos "${DISK}2"
if (( size_gib >= 12 )); then
  mkswap -L swap "${DISK}3"
fi

partprobe "$DISK"
udevadm settle --timeout=10

BOOT_PART="${DISK}1"
ROOT_PART="${DISK}2"
SWAP_PART="${DISK}3"

echo "=== Mounten ==="
mkdir -p "$MNT"
mount "$ROOT_PART" "$MNT"
mkdir -p "${MNT}/boot"
mount "$BOOT_PART" "${MNT}/boot"
if (( size_gib >= 12 )); then
  swapon "$SWAP_PART"
fi

echo "=== Flake kopieren ==="
mkdir -p "$NIXOS_DIR"
cp -a "${SRC}/." "$NIXOS_DIR/"

if ! nix eval --raw "${NIXOS_DIR}#nixosConfigurations.${FLAKE_ATTR}.config.system.name" >/dev/null 2>&1; then
  echo "NixOS-Konfiguration nicht gefunden: #nixosConfigurations.${FLAKE_ATTR}" >&2
  nix flake show "$NIXOS_DIR" >&2 || true
  exit 1
fi
echo "NixOS: #nixosConfigurations.${FLAKE_ATTR}"

echo "=== hardware-configuration.nix ==="
nixos-generate-config --root "$MNT"

echo "=== nixos-install ==="
nixos-install --flake "${NIXOS_DIR}#${FLAKE_ATTR}" --no-root-passwd

echo
echo "Fertig. Neustart: sudo reboot"
