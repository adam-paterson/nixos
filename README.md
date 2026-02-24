![Banner image](./assets/banner.png)

[![Nix Checks](https://img.shields.io/github/actions/workflow/status/adam-paterson/nixos/nix-checks.yml?label=Nix%20Checks&style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/adam-paterson/nixos/actions/workflows/nix-checks.yml)
[![Nix Cache Build](https://img.shields.io/github/actions/workflow/status/adam-paterson/nixos/nix-cache.yml?label=Nix%20Cache%20Build&style=for-the-badge&logo=cachix&logoColor=white)](https://github.com/adam-paterson/nixos/actions/workflows/nix-cache.yml)
[![Deploy Aurora](https://img.shields.io/github/actions/workflow/status/adam-paterson/nixos/deploy-aurora.yml?label=Deploy%20Aurora&style=for-the-badge&logo=nixos&logoColor=white)](https://github.com/adam-paterson/nixos/actions/workflows/deploy-aurora.yml)

# Nix Environments for macOS + Linux VPS (Snowfall Lib)

This repository manages two machines with one flake:

- `macbook` on `aarch64-darwin` (nix-darwin)
- `aurora` on `x86_64-linux` (NixOS)

Snowfall Lib auto-discovers systems, homes, and modules under `src/`.

## Layout

```text
src/
├── homes/
│   ├── aarch64-darwin/adampaterson@macbook/default.nix
│   └── x86_64-linux/adam@aurora/default.nix
├── modules/
│   ├── base.nix
│   ├── darwin/
│   │   ├── apps/homebrew/default.nix
│   │   ├── collections/{base,workstation}/default.nix
│   │   ├── services/tailscale/default.nix
│   │   └── system/{core,input}/default.nix
│   ├── home/
│   │   ├── apps/{cli,desktop}/...
│   │   ├── collections/{ai,base,cli,desktop,dev}/default.nix
│   │   ├── dev/{git,languages,neovim,shell,tailwind,tmux}/...
│   │   ├── prompts/{oh-my-posh,spaceship}/...
│   │   └── security/{onepassword-cli,ssh-agent-1password}/...
│   └── nixos/
│       ├── collections/{base,server,workstation}/default.nix
│       └── services/{cloudflared,tailscale}/default.nix
└── systems/
    ├── aarch64-darwin/macbook/default.nix
    └── x86_64-linux/aurora/
        ├── default.nix
        └── hardware/default.nix
```

## How Modules Are Applied

- `src/modules/home/collections/*` bundles Home Manager feature modules.
- `src/modules/darwin/collections/*` bundles Darwin feature modules.
- `src/modules/nixos/collections/*` bundles NixOS feature modules.

This keeps host files small and host-specific, while shared behavior lives in `modules/`.

## 1Password SSH Agent

SSH keys stay in 1Password. Nix only points SSH to the 1Password agent socket.

- macOS default socket: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- Linux default socket: `~/.1password/agent.sock`

Enable per-home with:

```nix
local.onePasswordSSH.enable = true;
```

## Spaceship Prompt

`src/modules/home/prompts/spaceship/default.nix` configures Spaceship for Zsh and is enabled by default.

Optional per-home overrides:

```nix
local.prompts.spaceship = {
  enable = true;
  addNewline = false;
  separateLine = false;
};
```

## OpenCode

`src/modules/home/apps/cli/opencode/default.nix` manages OpenCode CLI on both hosts and can manage `~/.config/opencode/opencode.json`.

Per-home options:

```nix
local.opencode = {
  enable = true;
  manageConfig = true;
  settings = { ... };      # rendered to JSON
  settingsFile = null;     # optional path to existing JSON file
  installDesktop = false;  # macOS desktop package
};
```

Note: at the currently pinned upstream revision, OpenCode desktop package eval is broken on `aarch64-darwin`; the module falls back to CLI-only and emits a warning when `installDesktop = true`.

## Cloudflared (aurora)

`src/modules/nixos/services/cloudflared/default.nix` adds a host-level wrapper around `services.cloudflared`.

Aurora wiring lives in:

- `src/systems/x86_64-linux/aurora/default.nix`

Example enablement:

```nix
local.cloudflared = {
  enable = true;
  tunnelId = "<tunnel-uuid>";
  credentialsFile = "/var/lib/cloudflared/<tunnel-uuid>.json";
  ingress = {
    "app.example.com" = "http://127.0.0.1:3000";
  };
  defaultService = "http_status:404";
};
```

Notes:

- Keep credentials JSON out of git.
- Place credentials on host (for example `/var/lib/cloudflared/<tunnel-uuid>.json`) with root-readable permissions.

## Commands

### Inspect outputs

```bash
nix flake show
```

### Developer Workflow

```bash
# List available tasks
just --list

# Auto-format + auto-fix lints
just fix

# Run parity checks with CI shell
just fmt-check
just lint
just check
just eval

# Full local CI pass
just ci
```

### Lockfile Workflow

Use `flake.lock` verify mode during normal work and explicit update commands for
intentional dependency changes. Policy and review checklist:

- `docs/flake-lock-workflow.md`

```bash
# Verify lock integrity without updating flake.lock
just lock-verify

# Sync lock entries when flake input declarations changed
just lock-sync

# Scoped input update (replace input name)
just lock-update nixpkgs
```

### Direnv + nixd (VS Code)

This repo provides a flake dev shell named `dev` with `nixd` and common Nix tooling.

```bash
# one-time
direnv allow

# manual shell entry (optional)
nix develop .#dev

# minimal CI shell (optional)
nix develop .#ci
```

The `.envrc` is configured to load `.#dev`, so entering the repo adds `nixd` to your environment.

### macOS (build + switch)

```bash
nix build .#darwinConfigurations.macbook.system
nix run nix-darwin -- switch --flake .#macbook
```

### Linux VPS (build + switch)

```bash
nix build .#nixosConfigurations.aurora.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#aurora
```

### Home Manager

```bash
home-manager switch --flake .#adampaterson@macbook
home-manager switch --flake .#adam@aurora
```

## Automation

- GitHub Actions lint/eval checks are defined in `.github/workflows/nix-checks.yml`.
- GitHub Actions cache build/push workflow is defined in `.github/workflows/nix-cache.yml`.
- GitHub Actions Aurora deploy workflow is defined in `.github/workflows/deploy-aurora.yml`.
- GitHub Actions Ubuntu container artifact build is defined in `.github/workflows/ubuntu-artifacts.yml`.
- Pre-commit hooks are managed by devenv in `src/shells/dev/default.nix`.

### CI and Cache Flow

`nix-checks.yml` runs on:

- pull requests
- pushes to `main`
- `workflow_dispatch` (manual)

`nix-cache.yml` runs on:

- successful completion of `nix-checks.yml` on `main`
- `workflow_dispatch` (manual)

It has two jobs:

- `Build Cache Targets`
- `Push Cache`

`deploy-aurora.yml` runs on:

- successful completion of `nix-cache.yml` on `main`
- `workflow_dispatch` (manual)

It builds and pushes these cache targets:

- Linux: `devShells.x86_64-linux.dev`, `nixosConfigurations.aurora.config.system.build.toplevel`
- macOS: `devShells.aarch64-darwin.dev`, `darwinConfigurations.macbook.system`, `homeConfigurations."adampaterson@macbook".activationPackage`

Required repository configuration for cache push and deploy:

- variable `CACHIX_CACHE_NAME` (recommended: `adam-paterson`)
- secret `CACHIX_AUTH_TOKEN`
- secret `CACHIX_ACTIVATE_TOKEN` (for `cachix deploy activate`)

Use `deploy-aurora.yml` for Aurora agent activation after cache builds.
Manual dispatch allows deploying a specific ref and/or custom Aurora agent name.

### Local Cache Target Commands

```bash
# Linux cache targets (same attrs as CI cache workflow)
just cache-targets-linux

# macOS cache targets (same attrs as CI cache workflow)
just cache-targets-macos
```

### Devenv Notes

- `devenv.root` is pinned in `src/shells/dev/default.nix` and `src/shells/ci/default.nix` so flake evaluation runs consistently.
- `cachix.pull = [ "adam-paterson" ]` is enabled in the dev shell for fast local substitute downloads.

### Ubuntu Container Artifact Validation

Build the Ubuntu-based Nix container and verify the Aurora system artifact:

```bash
docker build -f Containerfile -t nix-ubuntu-builder .
docker run --rm -v "$PWD:/work" -w /work nix-ubuntu-builder \
  bash -lc "nix build --print-build-logs --no-link .#nixosConfigurations.aurora.config.system.build.toplevel"
```

### Cachix Agent Bootstrap

Run this once per host after creating the agent/token in Cachix Deploy:

```bash
# Aurora (NixOS)
sudo CACHIX_AGENT_TOKEN="<token>" cachix deploy agent aurora system --bootstrap

# macbook (nix-darwin)
sudo CACHIX_AGENT_TOKEN="<token>" cachix deploy agent macbook system-profiles/system --bootstrap
```

Pre-commit hooks are installed automatically when entering the devenv shell.

## Important Notes

- Snowfall only discovers files tracked by git.
- System identifier `macbook` does not change your real macOS hostname; that remains set in `systems/aarch64-darwin/macbook/default.nix`.
- Replace `REPLACE_ME` SSH public key in `src/systems/x86_64-linux/aurora/default.nix`.
- Replace `src/systems/x86_64-linux/aurora/hardware-configuration.nix` with values generated on the server.
- For a truly headless VPS, 1Password agent requires an active desktop/session; otherwise use SSH agent forwarding from your laptop.
