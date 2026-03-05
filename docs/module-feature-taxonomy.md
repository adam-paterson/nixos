# Module Feature Taxonomy

## Scope & approach
- Covers every module subdirectory under `src/modules/home`, `src/modules/darwin`, and `src/modules/nixos`, plus the collection assemblies exposed through `*/collections/*`.
- Pulled each entry's intent from the corresponding `default.nix` and noted the programs/services it wires into the Cosmos configuration.
- The resulting taxonomy links feature buckets to paths so the migration work can point at the exact files that need to move.

## Shared baseline
| Module | Path | Feature bucket | Highlights |
|---|---|---|---|
| Shared base | `src/modules/base.nix` | Shared services / bootstrapping | Installs utility packages (`git`, `ripgrep`, `eza`, etc.) and shell aliases that every host imports through its collections.

## Home host modules
| Module | Path | Feature bucket | Highlights |
|---|---|---|---|
| Codex CLI config | `src/modules/home/apps/cli/codex/default.nix` | CLI | Exposes `programs.codex` when `cosmos.codex.enable` is flipped; the module is a simple toggle for the Codex app.
| OpenClaw | `src/modules/home/apps/cli/openclaw/default.nix` | CLI | Injects the upstream OpenClaw Home Manager module plus package override so the CLI is available when `cosmos.openclaw.enable` is true.
| OpenCode | `src/modules/home/apps/cli/opencode/default.nix` | CLI / desktop bridge | Installs the CLI, manages `~/.config/opencode/opencode.json`, and optionally pulls in the desktop package for macOS hosts.
| CLI package bundle | `src/modules/home/apps/cli/packages/default.nix` | CLI | Adds general utilities (`eza`, `nushell`, `direnv`, `nixd`, `gh`, `ripgrep`, `fd`, etc.) to every profile that imports the module.
| Ghostty terminal | `src/modules/home/apps/desktop/ghostty/default.nix` | Desktop/UX | Configures the GPU-accelerated Ghostty terminal with Catppuccin theme, JetBrains font, and macOS keybindings.
| Git tooling | `src/modules/home/dev/git/default.nix` | Programming/dev tooling | Enables Git/+Delta with Catppuccin theme, safe defaults (`rebase`, `merge.autoStash`, etc.), and pacing aliases.
| Language helpers | `src/modules/home/dev/languages/default.nix` | Programming/dev tooling | Drops Bun and Tailspin into `home.packages` for scripting and backend work.
| Neovim | `src/modules/home/dev/neovim/default.nix` | Programming/dev tooling | Opinionated Neovim config (LSPs, linters, formatters, AI+DAP toggles) plus the custom `nvim/init.lua` tree.
| Shell stack | `src/modules/home/dev/shell/default.nix` | Programming/dev tooling | Hooks in Bat, Eza, Zoxide, Direnv, Nushell, Bash, and Zsh with shared aliases to unify CLI workflows.
| Tailwind | `src/modules/home/dev/tailwind/default.nix` | Programming/dev tooling | Installs the `tailwindcss` CLI for front-end utilities.
| Tmux | `src/modules/home/dev/tmux/default.nix` | Programming/dev tooling | Crafts a Catppuccin-themed tmux config with Vim-style navigation, custom plugins, and session utilities.
| Oh My Posh prompt | `src/modules/home/prompts/oh-my-posh/default.nix` | CLI / Desktop | Enables the cross-shell Oh My Posh prompt for Bash, Zsh, and Nushell.
| Spaceship prompt | `src/modules/home/prompts/spaceship/default.nix` | CLI | Ships the Spaceship Zsh prompt with newline/separate-line controls and ensures `programs.zsh` loads it.
| 1Password CLI | `src/modules/home/security/onepassword-cli/default.nix` | Shared services | Installs `op`, generates an env file from vault secrets, and exposes aliases/completions for shells.
| 1Password SSH agent | `src/modules/home/security/ssh-agent-1password/default.nix` | Shared services | Points `SSH_AUTH_SOCK` at the 1Password agent socket, configures `programs.ssh`, and merges optional host blocks/bookmarks.

## Darwin host modules
| Module | Path | Feature bucket | Highlights |
|---|---|---|---|
| Homebrew bridge | `src/modules/darwin/apps/homebrew/default.nix` | Shared services | Enables the Nix-managed Homebrew overlay, pins taps, and makes `brew` available via `homebrew.enable`.
| Tailscale macOS | `src/modules/darwin/services/tailscale/default.nix` | Shared services | Installs the Tailscale app via Homebrew cask and exposes a `cosmos.tailscale` toggle to drop the binary into the profile.
| System defaults | `src/modules/darwin/system/core/default.nix` | Desktop/UX | Sweeps through Dock, Finder, Trackpad, Keyboard, and Software Update defaults to match the workstation's UX expectations.
| Input preferences | `src/modules/darwin/system/input/default.nix` | Desktop/UX | Provides options for Caps Lock remap, key repeat, keyboard layout, and trackpad/touchpad behavior plus the shared custom preferences defined under `system.defaults`.
| Darwin baseline collection | `src/modules/darwin/collections/base/default.nix` | Collection | Imports the shared `src/modules/base.nix` and the Homebrew module to form the baseline host profile.
| Darwin workstation collection | `src/modules/darwin/collections/workstation/default.nix` | Collection | Enables the `darwin.base` collection so a workstation can bootstrap all macOS-specific defaults and tooling.

## NixOS host modules
| Module | Path | Feature bucket | Highlights |
|---|---|---|---|
| Cloudflared | `src/modules/nixos/services/cloudflared/default.nix` | Shared services | Defines a reusable Cloudflare tunnel service with ingress mapping, CLI install toggle, and systemd service wiring for `cloudflared-tunnel-<id>`.
| Tailscale | `src/modules/nixos/services/tailscale/default.nix` | Shared services | Turns on `services.tailscale`, opens the firewall, and installs the binary from `pkgs.tailscale` when `cosmos.tailscale.enable` is true.
| NixOS baseline collection | `src/modules/nixos/collections/base/default.nix` | Collection | Imports `src/modules/base.nix` so every NixOS host starts with the shared package/alias baseline.
| NixOS server collection | `src/modules/nixos/collections/server/default.nix` | Collection | Builds on the base collection, enables `fail2ban`, hardens `security.sudo`, and configures `services.openssh` for a server posture.
| NixOS workstation collection | `src/modules/nixos/collections/workstation/default.nix` | Collection | Simply enables `cosmos.collections.nixos.base` to keep workstation hosts aligned with the shared baseline.

## Collections & assemblies
| Assembly | Path | Composition | Feature bucket |
|---|---|---|---|
| `cosmos.collections.home.base` | `src/modules/home/collections/base/default.nix` | Enables `programs.home-manager`, `cosmos.git`, `cosmos.shell`, `onePasswordCLI`, `onePasswordSSH`, and `prompts.spaceship`. | Shared services / CLI shell
| `cosmos.collections.home.ai` | `src/modules/home/collections/ai/default.nix` | Switches on `opencode` and `neovim.enableAI`. | Programming/dev tooling (AI)
| `cosmos.collections.home.cli` | `src/modules/home/collections/cli/default.nix` | Enables `opencode` with desktop install disabled by default. | CLI
| `cosmos.collections.home.desktop` | `src/modules/home/collections/desktop/default.nix` | Toggles `ghostty` and `oh-my-posh` for a consistent terminal UX. | Desktop/UX
| `cosmos.collections.home.dev` | `src/modules/home/collections/dev/default.nix` | Enables `neovim`, `tailwind`, and `tmux` along with LSP stacks; central point for dev tooling. | Programming/dev tooling
| `cosmos.collections.darwin.base` | `src/modules/darwin/collections/base/default.nix` | Imports `src/modules/base.nix` and the Homebrew module. | Shared services
| `cosmos.collections.darwin.workstation` | `src/modules/darwin/collections/workstation/default.nix` | Enables the Darwin base collection. | Desktop/UX
| `cosmos.collections.nixos.base` | `src/modules/nixos/collections/base/default.nix` | Imports `src/modules/base.nix`. | Shared services
| `cosmos.collections.nixos.server` | `src/modules/nixos/collections/server/default.nix` | Builds on `nixos.base` and adds `fail2ban`, SSH hardening, and sudo limits. | Shared services
| `cosmos.collections.nixos.workstation` | `src/modules/nixos/collections/workstation/default.nix` | Enables the NixOS base collection. | Programming/dev tooling / baseline

## Observations (duplicates & gaps)
1. **Duplication through collections.** The `home` collections simply toggle the leaf modules (`neovim`, `opencode`, `ghostty`, etc.), so migrating a collection means moving both the collection wrapper and the underlying module; the same is true for the `darwin`/`nixos` collections that import `src/modules/base.nix` plus host-specific additions.
2. **Security modules live outside collections.** The 1Password CLI/SSH modules (`home/security/*`) are not part of any collection, so the migration plan needs to decide whether to fold them into `cosmos.collections.home.base` or keep them as standalone security modules on each host.
3. **Host-specific shared services are sparse.** Only Tailscale (both hosts) and Cloudflared (NixOS) are defined under `services/`; there is no shared-services analog on `darwin` for Cloudflared or on `home` for Tailscale, which leaves these buckets incomplete if the migration needs consistent VPN/tunnel coverage.
