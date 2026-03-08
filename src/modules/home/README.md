# Home Modules Contract

## Purpose

`src/modules/home/` contains reusable Home Manager modules for cross-host user environment composition.

## Taxonomy

Use feature-first, tool-specific placement:

- `shells/` for shell UX and shell-adjacent tools.
- `prompts/` for prompt engines.
- `terminals/` for terminal applications.
- `editors/`, `runtimes/`, `vcs/`, `frontend/`, `cli/`, `desktop/`, `security/` for tool families.
- `collections/` only for composition bundles (no direct tool config logic).

Each tool module must live at:

- `src/modules/home/<feature-area>/<tool>/default.nix`

Examples:

- `shells/nushell/default.nix`
- `shells/completions/carapace/default.nix`
- `cli/codex/default.nix`
- `terminals/wezterm/default.nix`

## Option Naming

All Home options use hierarchical namespace paths:

- `${namespace}.home.<feature-area>.<tool>...`

Examples:

- `${namespace}.home.shells.nushell.enable`
- `${namespace}.home.cli.opencode.enable`
- `${namespace}.home.security.onePasswordSSH.enable`
- `${namespace}.home.collections.dev.enable`

## What Goes Here

- User-layer policy intended to be reusable across hosts.
- One module per app/tool, including package installation and tool configuration.
- Cross-host defaults wired through collection modules.

## What Does Not

- System-level Darwin or NixOS policy.
- Host-only user facts tied to one machine.
- Secret payload values.
- Mixed bundle modules for unrelated tools.

## Migration Rules

- Use hard moves when reorganizing modules.
- Update references in the same change.
- Do not keep old path aliases or compatibility wrappers.
