# ARM64 ISO auf macOS bauen

## Problem

NixOS-Systeme können nicht direkt auf macOS gebaut werden, auch wenn beide ARM64 sind. Du brauchst entweder:

1. **Einen Remote Builder** (Linux-Server mit aarch64-linux)
2. **Ein Linux-System** zum Bauen

## Option 1: Remote Builder einrichten

### Schritt 1: Linux-Server vorbereiten

Auf einem Linux-Server (z.B. Hetzner Cloud ARM64 Instance):

```bash
# Nix installieren
sh <(curl -L https://nixos.org/nix/install) --daemon

# SSH-Zugriff konfigurieren
# Stelle sicher, dass SSH-Key-Authentifizierung funktioniert
```

### Schritt 2: Remote Builder konfigurieren

Auf deinem Mac, in `/etc/nix/nix.conf` oder `~/.config/nix/nix.conf`:

```nix
builders = ssh://user@linux-server aarch64-linux /path/to/nix/store /path/to/nix/store 1 1
```

Oder temporär beim Build:

```bash
nix build '.#packages.aarch64-linux.iso' \
  --builders 'ssh://user@linux-server aarch64-linux /nix/store /nix/store 1 1'
```

### Schritt 3: ISO bauen

```bash
nix build '.#packages.aarch64-linux.iso'
```

## Option 2: Auf Linux-System bauen

### Auf einem Linux-System (z.B. Ubuntu ARM64):

```bash
# Repository klonen
git clone <dein-repo>
cd helferlein-nix

# ISO bauen
nix build '.#packages.aarch64-linux.iso'

# ISO finden
ls -lh ./result/iso/
```

## Option 3: GitHub Actions (empfohlen)

Falls du GitHub Actions verwendest, kannst du dort automatisch bauen lassen.

## Aktuelle Konfiguration

Die Flake ist bereits für ARM64 konfiguriert:
- `iso-image` verwendet `iso-image-arm.nix`
- System: `aarch64-linux`
- ISO-Name: `nixos-akkoma-arm64-*-aarch64-linux.iso`

## Troubleshooting

**Fehler: "required system or feature not available"**
- Du brauchst einen Remote Builder oder musst auf Linux bauen

**Fehler: "ignoring the client-specified setting 'system'"**
- `--system` ist eine restricted setting, verwende stattdessen Remote Builder

**Remote Builder funktioniert nicht:**
- Prüfe SSH-Verbindung: `ssh user@linux-server`
- Prüfe Nix-Installation auf Remote-Server
- Prüfe `/etc/nix/nix.conf` auf dem Remote-Server



