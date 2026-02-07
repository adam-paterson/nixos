# Nix Environments for macOS + Linux VPS (Snowfall Lib)

This repository manages two machines with one flake:

- `macbook` on `aarch64-darwin` (nix-darwin)
- `aurora` on `x86_64-linux` (NixOS)

Snowfall Lib auto-discovers systems, homes, and modules under `src/`.

## Layout

```text
src/
├── homes/
│   ├── aarch64-darwin/
│   │   └── adampaterson@macbook/default.nix
│   └── x86_64-linux/
│       └── adam@aurora/default.nix
├── modules/
│   ├── base.nix
│   ├── darwin/
│   │   └── base/default.nix
│   ├── home/
│   │   └── common/
│   │       ├── default.nix
│   │       ├── git.nix
│   │       ├── packages.nix
│   │       ├── shell.nix
│   │       ├── spaceship.nix
│   │       └── ssh-agent-1password.nix
│   └── nixos/
│       ├── base/default.nix
│       └── server/default.nix
└── systems/
    ├── aarch64-darwin/
    │   └── macbook/default.nix
    └── x86_64-linux/
        └── aurora/
            ├── default.nix
            └── hardware-configuration.nix
```

## How Modules Are Applied

- `src/modules/home/*` modules apply to all Home Manager profiles.
- `src/modules/darwin/*` modules apply to all darwin systems.
- `src/modules/nixos/*` modules apply to all NixOS systems.

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

`src/modules/home/common/spaceship.nix` configures Spaceship for Zsh and is enabled by default.

Optional per-home overrides:

```nix
local.prompts.spaceship = {
  enable = true;
  addNewline = false;
  separateLine = false;
};
```

## Commands

### Inspect outputs

```bash
nix flake show
```

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

## Important Notes

- Snowfall only discovers files tracked by git.
- System identifier `macbook` does not change your real macOS hostname; that remains set in `systems/aarch64-darwin/macbook/default.nix`.
- Replace `REPLACE_ME` SSH public key in `src/systems/x86_64-linux/aurora/default.nix`.
- Replace `src/systems/x86_64-linux/aurora/hardware-configuration.nix` with values generated on the server.
- For a truly headless VPS, 1Password agent requires an active desktop/session; otherwise use SSH agent forwarding from your laptop.
