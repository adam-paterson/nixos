# NixOS Modules Contract

## Purpose

`src/modules/nixos/` contains reusable NixOS policy, services, collections, and host override modules.

## What goes here

- NixOS capability modules for Linux system behavior and services.
- Collection bundles used by server/workstation system composition.
- Host-specific override modules when a host exception cannot live in shared policy.

## What does not

- nix-darwin-only settings.
- Home Manager user-layer features.
- Host facts and machine metadata that should stay in `src/systems/...`.
- Secret values or sensitive files.

## Naming

- Use capability-first names (`services/cloudflared`, `services/tailscale`).
- Keep collection names composition-oriented (`collections/server`, `collections/workstation`).
- Put host exceptions in `overrides/<host>/default.nix` and avoid broad catch-all modules.

## Examples

- `services/cloudflared/default.nix` for reusable service wiring.
- `collections/server/default.nix` for server baseline composition.
- `overrides/aurora/default.nix` for aurora-only exceptions.

## Exception process

1. Prefer reusable NixOS capability modules.
2. If only one host needs the behavior, isolate it in the matching override module.
3. If placement still conflicts, capture a short decision note and follow up in architecture docs.
