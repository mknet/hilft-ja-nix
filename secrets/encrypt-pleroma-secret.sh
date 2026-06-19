#!/usr/bin/env bash
# Pleroma secret.exs als pleroma-secret.age verschlüsseln.
#
#   ./encrypt-pleroma-secret.sh helferlein-server
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

HOST="${1:?hostname, z.B. helferlein-server}"
SRC="${2:-$SCRIPT_DIR/pleroma-secret.exs}"
OUT="$SCRIPT_DIR/$HOST/pleroma-secret.age"

if ! command -v age &>/dev/null; then
  echo "age nicht gefunden" >&2
  exit 1
fi

if [[ ! -f "$SRC" ]]; then
  echo "Quelldatei fehlt: $SRC" >&2
  echo "Kopiere pleroma-secret.exs.example nach pleroma-secret.exs und fülle Secrets aus." >&2
  exit 1
fi

mkdir -p "$SCRIPT_DIR/$HOST"
HOST_PUB="$SCRIPT_DIR/$HOST/host.pub"
if [[ ! -f "$HOST_PUB" ]]; then
  echo "Host-Key fehlt: $HOST_PUB" >&2
  echo "ssh root@<host> 'cat /etc/ssh/ssh_host_ed25519_key.pub' > $HOST_PUB" >&2
  exit 1
fi

RECIPS=( -R "$HOST_PUB" )
if [[ -f "${SSH_AUTH_PUB:-$HOME/.ssh/id_ed25519.pub}" ]]; then
  RECIPS+=( -R "${SSH_AUTH_PUB:-$HOME/.ssh/id_ed25519.pub}" )
fi

age -e "${RECIPS[@]}" -o "$OUT" < "$SRC"
echo "Wrote $OUT"
