#!/bin/bash

set -e

echo "=== Lokaler NixOS ISO Build ==="

# Check if Nix is available
if ! command -v nix-build &> /dev/null; then
    echo "Nix is not installed. Please install Nix first."
    exit 1
fi

# Create output directory
mkdir -p out

echo "Building ISO locally (this may take a very long time)..."

# Try building with different configurations
echo "=== Attempt 1: Stable configuration ==="
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso-image-stable.nix --out-link result-iso-stable || echo "Stable build failed"

if [ -L result-iso-stable ] && [ -d result-iso-stable/iso ]; then
  echo "✓ Stable build succeeded!"
  cp result-iso-stable/iso/*.iso out/ 2>/dev/null || true
  echo "✓ ISO copied to out/"
else
  echo "❌ Stable build failed, trying minimal approach..."
  
  echo "=== Attempt 2: Minimal configuration ==="
  nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso-minimal.nix --out-link result-iso-minimal || echo "Minimal build failed"
  
  if [ -L result-iso-minimal ] && [ -d result-iso-minimal/iso ]; then
    echo "✓ Minimal build succeeded!"
    cp result-iso-minimal/iso/*.iso out/ 2>/dev/null || true
    echo "✓ Minimal ISO copied to out/"
  else
    echo "❌ All local builds failed"
  fi
fi

echo "=== Build completed ==="
ls -la out/

