# Systems Composition Contract

## Purpose

`src/systems/` defines thin host composition for system targets. Host files are composition points, not policy warehouses.

## What goes here

- Host facts (hostname, architecture-specific references, hardware imports).
- Imports and toggles that enable reusable module collections.
- Host-local references to secret locations (not secret values).

## What does not

- Reusable system policy that belongs in `src/modules/darwin/` or `src/modules/nixos/`.
- Large service definitions or package policy duplicated across hosts.
- Cross-host behavior that should be modeled as a collection or capability module.

## Naming

- Keep host directory names explicit (`aarch64-darwin/macbook`, `x86_64-linux/aurora`).
- Keep files minimal and readable; prefer one `default.nix` per host composition root.
- Name host toggles for intent, not implementation detail.

## Examples

- Good host file contents:
  - host facts (`networking.hostName`)
  - collection toggles (`cosmos.collections.nixos.server.enable = true;`)
  - host-local override toggle (`cosmos.overrides.aurora.enable = true;`)
- Not good:
  - embedding full service policy directly in host files.

## Exception process

1. If a host needs one-off behavior, create or extend an override module under `src/modules/*/overrides/<host>/`.
2. Keep host files to facts, imports, and toggles only.
3. If an exception cannot be modeled without host sprawl, log decision rationale in plan summary.
