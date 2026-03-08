# Module Taxonomy

This document defines canonical module placement and option naming for this repository.

## Canonical Naming

### Directory taxonomy

Use:

- `src/modules/<platform-root>/<feature-area>/<tool>/default.nix`

Examples:

- `src/modules/home/shells/nushell/default.nix`
- `src/modules/home/shells/completions/carapace/default.nix`
- `src/modules/home/cli/codex/default.nix`
- `src/modules/home/terminals/wezterm/default.nix`

### Option taxonomy

Use hierarchical option paths:

- Home: `${namespace}.home.<feature-area>.<tool>...`
- Darwin (standard): `${namespace}.darwin.<feature-area>.<tool>...`
- NixOS (standard): `${namespace}.nixos.<feature-area>.<tool>...`

Examples:

- `${namespace}.home.shells.nushell.enable`
- `${namespace}.home.shells.completions.carapace.enable`
- `${namespace}.home.cli.opencode.enable`
- `${namespace}.home.security.onePasswordSSH.enable`
- `${namespace}.home.collections.dev.enable`

## Home Taxonomy Map

```text
src/modules/home/
├── shells/
│   ├── bash/default.nix
│   ├── zsh/default.nix
│   ├── nushell/default.nix
│   ├── environment/path/default.nix
│   ├── environment/direnv/default.nix
│   ├── completions/carapace/default.nix
│   ├── navigation/zoxide/default.nix
│   ├── listing/eza/default.nix
│   └── viewers/bat/default.nix
├── prompts/
├── terminals/
├── editors/
├── runtimes/
├── vcs/
├── frontend/
├── cli/
├── desktop/
├── security/
└── collections/
```

## Module Rules

1. One module per app/tool.
2. A tool module owns package installation and that tool's config only.
3. Collections are composition-only modules.
4. No mixed package bundles for unrelated tools.
5. Use hard moves for reorganizations (no alias paths).

## Migration Checklist

1. Move module to canonical path.
2. Rename options to `${namespace}.home.<feature-area>.<tool>...`.
3. Update collections to the new option path.
4. Update `src/homes/*` toggles to the new option path.
5. Remove old module path (no wrappers).
6. Run `rg` checks for old option paths.
7. Build Home configs for macbook + aurora.

## Where To Put X

- Nushell core config: `src/modules/home/shells/nushell/default.nix`
- Carapace completion: `src/modules/home/shells/completions/carapace/default.nix`
- Zoxide: `src/modules/home/shells/navigation/zoxide/default.nix`
- Eza: `src/modules/home/shells/listing/eza/default.nix`
- Direnv: `src/modules/home/shells/environment/direnv/default.nix`
- Codex: `src/modules/home/cli/codex/default.nix`
- OpenCode: `src/modules/home/cli/opencode/default.nix`
- WezTerm: `src/modules/home/terminals/wezterm/default.nix`
- Tmux: `src/modules/home/terminals/tmux/default.nix`
- Neovim: `src/modules/home/editors/neovim/default.nix`
- Tailwind: `src/modules/home/frontend/tailwind/default.nix`
