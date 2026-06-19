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
- `nixos-akkoma-iso-universal` - Universelles Installations-Image (funktioniert auf allen Plattformen)
- Beide ISOs enthalten die gleichen Konfigurationsdateien

## 🎯 Installation

### 🖥️ Vagrant (Entwicklung)

**Für lokale Entwicklung:**
```bash
# 1. Vagrant VM erstellen und starten
./vagrant-setup.sh

# 2. NixOS in VM installieren
./vagrant-nixos-deploy.sh

# 3. SSH in NixOS VM
vagrant ssh
```

**Vagrant Box:** `bento/ubuntu-22.04` (am beliebtesten)  
**VM Ressourcen:** 4GB RAM, 2 CPUs  
**Netzwerk:** 192.168.56.10  

### 🖥️ Parallels Desktop (macOS)

**Für alle Macs (Intel + Apple Silicon):**
```bash
# Universelles ISO in Parallels importieren
prlctl create "NixOS-Akkoma" --ostype linux
prlctl set "NixOS-Akkoma" --device-add cd --image nixos-akkoma-iso-universal-*.iso
prlctl start "NixOS-Akkoma"
```

### ☁️ Cloud Deployment

#### **Option 1: Terraform + Hetzner Cloud (Empfohlen)**
```bash
# 1. Terraform konfigurieren
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Bearbeiten Sie terraform.tfvars mit Ihren Daten

# 2. Server erstellen und NixOS installieren
terraform init
terraform plan
terraform apply

# 3. SSH-Zugriff
ssh root@<server-ip>
```

#### **Option 2: nixos-anywhere (Direktes Deployment)**
```bash
# NixOS direkt auf Hetzner Server deployen
./deploy-nixos-hetzner.sh <server-ip>
```

#### **Option 3: Andere Cloud-Anbieter**
```bash
# DigitalOcean
./deploy-digitalocean.sh

# Vultr
./deploy-vultr.sh

# Hetzner (Rescue-System)
./deploy-hetzner-rescue.sh
```

### 📚 Vollständige Anleitung
Siehe [CLOUD-DEPLOYMENT.md](CLOUD-DEPLOYMENT.md) für detaillierte Anweisungen.

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
