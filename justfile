# Helferlein NixOS

check:
    bash -l -c 'nix flake check --no-build --impure 2>&1 || true'
    bash -l -c 'nix eval --json --impure .#nixosConfigurations.helferlein.config.system.name'

check-config:
    bash -l -c 'nix eval --json --impure .#nixosConfigurations.helferlein.config.system.name'

format:
    bash -l -c 'nix fmt'

list:
    bash -l -c 'nix flake show'

build-iso:
    bash -l -c 'nix build .#iso'

shell:
    bash -l -c 'nix develop'

copy-to-fresh-test:
    rsync -avzL --exclude='.git' $PWD/ nixos@192.168.65.6:/home/nixos/nix

copy-to-test:
    rsync -avzL --exclude='.git' $PWD/ marcel@192.168.65.6:/home/marcel/nix

switch:
    bash scripts/switch.sh
