# NixOS Akkoma Server ISO Builder

Dieses Repository baut ein vollständiges NixOS ISO Image mit:
- **Akkoma** (Fediverse Server)
- **Jitsi Meet** (Video Conferencing)
- **PostgreSQL** (Database)
- **Nginx** (Web Server)
- **Redis** (Caching)

## 🚀 GitHub Actions Build

Der Build läuft automatisch in GitHub Actions mit:
- **32GB RAM**
- **8 CPU Cores**
- **Unbegrenzte Build-Zeit**
- **Automatische Artefakt-Upload**

## 📁 Repository Struktur

```
├── .github/workflows/build-iso.yml    # GitHub Actions Workflow
├── configuration.nix                  # Haupt-NixOS Konfiguration
├── environment.nix                    # Umgebungsvariablen
├── iso-image.nix                      # ISO Image Konfiguration
└── README.md                          # Diese Datei
```

## 🔧 Verwendung

1. **Fork** dieses Repository
2. **Push** zu Ihrem Fork
3. **GitHub Actions** startet automatisch
4. **Download** das ISO aus den Artefakten

## 📋 Build-Ergebnisse

Nach erfolgreichem Build finden Sie:
- `nixos-akkoma-iso-x86_64` - Bootbares Installations-Image (Intel/AMD)
- `nixos-akkoma-iso-arm64` - Bootbares Installations-Image (ARM64/Apple Silicon)
- Beide ISOs enthalten die gleichen Konfigurationsdateien

## 🎯 Installation

### Parallels Desktop (macOS)

**Für Intel Mac:**
```bash
# x86_64 ISO in Parallels importieren
prlctl create "NixOS-Akkoma-x86" --ostype linux
prlctl set "NixOS-Akkoma-x86" --device-add cd --image nixos-akkoma-iso-x86_64-*.iso
prlctl start "NixOS-Akkoma-x86"
```

**Für ARM Mac (Apple Silicon):**
```bash
# ARM64 ISO in Parallels importieren
prlctl create "NixOS-Akkoma-ARM" --ostype linux
prlctl set "NixOS-Akkoma-ARM" --device-add cd --image nixos-akkoma-iso-arm64-*.iso
prlctl start "NixOS-Akkoma-ARM"
```

### Cloud Deployment
```bash
# ISO in Cloud Provider hochladen (Hetzner, DigitalOcean, etc.)
# Wählen Sie die richtige Architektur für Ihren Server
```

## ⚙️ Konfiguration

Bearbeiten Sie `environment.nix` für Ihre Domain:
```nix
{
  current = {
    domain = "ihre-domain.com";
    email = "admin@ihre-domain.com";
  };
}
```

## 🔍 Troubleshooting

Bei Build-Problemen:
1. Checken Sie die GitHub Actions Logs
2. Verifizieren Sie die NixOS Konfiguration
3. Testen Sie mit minimaler Konfiguration

## 📚 Links

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Akkoma Documentation](https://docs.akkoma.dev/)
- [Jitsi Meet Documentation](https://jitsi.github.io/handbook/)
