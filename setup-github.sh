#!/bin/bash

# GitHub Repository Setup Script
# Dieses Script hilft beim Einrichten des GitHub Repositories

set -e

echo "=== GitHub Repository Setup für NixOS Akkoma Server ==="
echo ""

# Prüfen ob git initialisiert ist
if [ ! -d ".git" ]; then
    echo "Git Repository initialisieren..."
    git init
    echo "✓ Git Repository initialisiert"
else
    echo "✓ Git Repository bereits vorhanden"
fi

# Dateien hinzufügen
echo "Dateien zum Git Repository hinzufügen..."
git add .
echo "✓ Dateien hinzugefügt"

# Erste Commit
echo "Erste Commit erstellen..."
git commit -m "Initial commit: NixOS Akkoma Server ISO Builder

- GitHub Actions Workflow für automatischen ISO Build
- Vollständige NixOS Konfiguration mit Akkoma + Jitsi
- Automatische Artefakt-Upload nach erfolgreichem Build
- Dokumentation und Setup-Anweisungen"
echo "✓ Erste Commit erstellt"

echo ""
echo "=== Nächste Schritte ==="
echo ""
echo "1. Erstellen Sie ein neues Repository auf GitHub:"
echo "   https://github.com/new"
echo ""
echo "2. Verbinden Sie das lokale Repository:"
echo "   git remote add origin https://github.com/IHR-USERNAME/IHR-REPO.git"
echo ""
echo "3. Pushen Sie den Code:"
echo "   git push -u origin main"
echo ""
echo "4. GitHub Actions startet automatisch den Build!"
echo ""
echo "5. Nach erfolgreichem Build:"
echo "   - Gehen Sie zu 'Actions' in Ihrem GitHub Repository"
echo "   - Klicken Sie auf den letzten Workflow-Run"
echo "   - Laden Sie die Artefakte herunter (ISO, QCOW2)"
echo ""
echo "=== Konfiguration anpassen ==="
echo ""
echo "Bearbeiten Sie environment.nix für Ihre Domain:"
echo "  - domain = \"ihre-domain.com\""
echo "  - email = \"admin@ihre-domain.com\""
echo "  - Passwörter ändern!"
echo ""
echo "=== Optional: Cachix Cache ==="
echo ""
echo "Für schnellere Builds können Sie einen Cachix Cache einrichten:"
echo "1. Gehen Sie zu https://cachix.org"
echo "2. Erstellen Sie einen Cache"
echo "3. Fügen Sie CACHIX_AUTH_TOKEN zu GitHub Secrets hinzu"
echo ""
echo "Setup abgeschlossen! 🚀"
