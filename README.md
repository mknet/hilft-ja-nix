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
- `akkoma-server-*.iso` - Bootbares Installations-Image
- `akkoma-server-*.qcow2` - Cloud-Image (Hetzner, etc.)
- `akkoma-server-*.raw` - Parallels Desktop Image

## 🎯 Installation

### Parallels Desktop (macOS)
```bash
# ISO in Parallels importieren
prlctl create "NixOS-Akkoma" --ostype linux
prlctl set "NixOS-Akkoma" --device-add cd --image akkoma-server-*.iso
prlctl start "NixOS-Akkoma"
```

### Hetzner Cloud
```bash
# QCOW2 Image hochladen
hcloud image create --type snapshot --name "akkoma-server" akkoma-server-*.qcow2
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
