# Module Architecture Contract

## Purpose

`src/modules/` is the canonical placement contract for reusable configuration policy.
Organize modules by capability first, then by platform boundary where needed.

## What goes here

- Reusable policy that should be shared by more than one host.
- Capability modules under explicit platform roots:
  - `src/modules/darwin/` for nix-darwin-only modules.
  - `src/modules/nixos/` for NixOS-only modules.
  - `src/modules/home/` for Home Manager user-layer modules.
- Collection modules that bundle multiple capabilities for host composition.
- Truly shared baseline modules (for example `src/modules/base.nix`) when logic is platform-neutral.

## What does not

- Host facts (hostnames, hardware paths, machine-local IDs).
- Secret material or plaintext credentials.
- One-off host policy that applies to exactly one machine.
- Alias compatibility layers for moved modules.

## Naming

- Use explicit, capability-first names (`services/tailscale`, `collections/workstation`).
- Avoid ambiguous buckets like `misc`, `core`, or `temp`.
- Keep names verbose enough to make ownership obvious to a new contributor.
- Use hard moves for renames or reorganizations; update imports and references in the same change.

## Examples

- Good:
  - `src/modules/darwin/services/tailscale/default.nix`
  - `src/modules/nixos/collections/server/default.nix`
  - `src/modules/home/dev/git/default.nix`
- Good shared conditional use:
  - A small platform conditional in a shared module is allowed when it is obvious,
    documented, and clearly reduces duplication.
- Not good:
  - Embedding machine-only policy in `src/modules/...` instead of host overrides.
  - Keeping old and new module paths active after migration.

## Exception process

If placement is unclear:

1. Start from capability-first placement in this directory.
2. If behavior is host-specific, move it to host-local overrides under `src/systems/` or `src/homes/`.
3. If a shared module needs a small platform branch, document the reason inline and keep scope narrow.
4. If still uncertain, add a short decision note in the relevant plan summary before merging.

## Platform boundaries

- Darwin modules configure nix-darwin options and macOS-specific tooling.
- NixOS modules configure NixOS options/services and Linux host behavior.
- Home modules configure user-level behavior shared across supported hosts.
- Host composition should enable these modules via collections; do not re-implement policy in host files.

## Migration policy

- Use hard moves only: move files to the new canonical location and update references immediately.
- Do not create alias imports, duplicate wrappers, or long-lived compatibility paths.
- Ensure `README` contracts are updated in the same change when structure changes.

## Local contracts

- `src/modules/darwin/README.md`
- `src/modules/nixos/README.md`
- `src/modules/home/README.md`
