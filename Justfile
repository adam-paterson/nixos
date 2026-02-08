set shell := ["bash", "-euo", "pipefail", "-c"]
aurora_user := "adam"
aurora_host := "aurora-1.taileb2c54.ts.net"

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

switch-macbook:
  nix run nix-darwin -- switch --flake path:.#macbook

switch-aurora:
  if [ "${EUID}" -eq 0 ]; then echo "Run 'just switch-aurora' as your normal user (not via sudo)." >&2; exit 1; fi
  nix run nixpkgs#nixos-rebuild -- switch --flake path:.#aurora --build-host {{aurora_user}}@{{aurora_host}} --target-host {{aurora_user}}@{{aurora_host}} --sudo --ask-sudo-password

ci: fmt-check lint check eval

# Fast, local pre-deploy checks for OpenClaw on the aurora config.
# This validates that:
# - the adam and rachel instances evaluate
# - expected gateway ports are present
# - generated OpenClaw files/services are emitted by Home Manager
test-openclaw-aurora:
  nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances' | jq -e 'has("adam") and has("rachel") and (has("default") | not)'
  nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances.adam.gatewayPort' | jq -e '. == 18789'
  nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances.rachel.gatewayPort' | jq -e '. == 18810'
  nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.home.file' | jq -e 'has(".openclaw-adam/openclaw.json") and has(".openclaw-rachel/openclaw.json") and has("/home/adam/.config/systemd/user/openclaw-gateway-adam.service") and has("/home/adam/.config/systemd/user/openclaw-gateway-rachel.service")'
  @echo "OpenClaw aurora eval smoke test passed."

# Full NixOS eval/build graph check (no switch).
build-aurora-system:
  nix build '.#nixosConfigurations."aurora".config.system.build.toplevel' --dry-run

# Recommended pre-deploy for aurora OpenClaw changes.
predeploy-openclaw: fmt-check lint test-openclaw-aurora build-aurora-system
