set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

_run task:
  @if command -v {{task}} >/dev/null 2>&1; then {{task}}; else nix develop "path:$PWD#ci" -c {{task}}; fi

fmt-check:
  @just _run fmt-check

lint:
  @just _run lint

check:
  @just _run check

eval:
  @just _run eval

flake-contract:
  @just _run flake-contract

fix:
  @just _run fix

ci:
  @just _run ci

secrets-scan:
  @just _run secrets-scan

pre-apply-check:
  @just _run fmt-check
  @just _run lint
  @just _run check
  @just _run eval
  @just _run flake-contract
  @just _run secrets-scan

secrets-scan-full:
  @SECRETS_SCAN_SCOPE=full just secrets-scan

secrets-auth-preflight:
  @if ! command -v op >/dev/null 2>&1; then \
    echo "1Password CLI (op) is required. Install it and retry."; \
    exit 1; \
  fi
  @if ! op whoami >/dev/null 2>&1; then \
    echo "1Password authentication missing. Run 'op signin' or export OP_SERVICE_ACCOUNT_TOKEN, then retry."; \
    exit 1; \
  fi

secrets-edit-shared:
  @just secrets-auth-preflight
  @sops secrets/shared/common.yaml

secrets-edit-aurora:
  @just secrets-auth-preflight
  @sops secrets/hosts/aurora.yaml

secrets-edit-macbook:
  @just secrets-auth-preflight
  @sops secrets/hosts/macbook.yaml

secrets-updatekeys:
  @sops updatekeys --yes secrets/shared/common.yaml
  @sops updatekeys --yes secrets/hosts/aurora.yaml
  @sops updatekeys --yes secrets/hosts/macbook.yaml

secrets-age-public-key key_file="${HOME}/.config/sops/age/keys.txt":
  @if [ ! -f "{{key_file}}" ]; then \
    echo "Age key file not found: {{key_file}}"; \
    exit 1; \
  fi
  @grep '^# public key: ' "{{key_file}}" | sed 's/^# public key: //'

secrets-mock-check:
  @SECRETS_SCAN_SCOPE=working-tree just secrets-scan
  @just eval
  @nix build --dry-run .#darwinConfigurations.macbook.system
  @nix build --dry-run .#nixosConfigurations.aurora.config.system.build.toplevel

secrets-apply-macbook:
  @just secrets-auth-preflight
  @nix run nix-darwin -- switch --flake .#macbook

secrets-deploy-aurora:
  @just secrets-auth-preflight
  @sudo nixos-rebuild switch --flake .#aurora

home-build-macbook:
  @nix build .#homeConfigurations."adampaterson@macbook".activationPackage

home-build-aurora:
  @nix build .#homeConfigurations."adam@aurora".activationPackage

home-switch-macbook:
  @home-manager switch --flake .#adampaterson@macbook

home-switch-aurora:
  @home-manager switch --flake .#adam@aurora

home-check:
  @just home-build-macbook
  @just home-build-aurora

cache-targets-linux:
  @just _run cache-targets-linux

cache-targets-macos:
  @just _run cache-targets-macos

ubuntu-build-aurora:
  @just _run ubuntu-build-aurora

lock-verify:
  @before=$(shasum flake.lock | cut -d' ' -f1); \
  nix flake lock --no-update-lock-file; \
  after=$(shasum flake.lock | cut -d' ' -f1); \
  test "$before" = "$after"

lock-sync:
  @nix flake lock

lock-update input:
  @nix flake update --update-input {{input}}
