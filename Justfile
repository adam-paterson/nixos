set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

fmt:
  nix run nixpkgs#alejandra -- .

fmt-check:
  nix run nixpkgs#alejandra -- --check .

lint:
  nix run nixpkgs#deadnix -- .

fix:
  nix run nixpkgs#alejandra -- .
  nix run nixpkgs#statix -- fix .
  nix run nixpkgs#deadnix -- --edit .

check:
  nix flake show path:.

eval:
  nix eval .#nixosConfigurations.aurora.config.networking.hostName
  nix eval .#nixosConfigurations.aurora.config.system.stateVersion
  nix eval .#darwinConfigurations.macbook.config.networking.hostName
  nix eval '.#homeConfigurations."adam@aurora".activationPackage.drvPath'
  nix eval '.#homeConfigurations."adampaterson@macbook".activationPackage.drvPath'

build-aurora:
  nix build '.#homeConfigurations."adam@aurora".activationPackage' --dry-run

build-macbook:
  nix build '.#homeConfigurations."adampaterson@macbook".activationPackage' --dry-run

ci: fmt-check lint check eval
