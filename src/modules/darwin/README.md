# Darwin Modules Contract

## Purpose

`src/modules/darwin/` contains reusable nix-darwin policy and collections for macOS hosts.

## What goes here

- nix-darwin capability modules for macOS behavior.
- Reusable Darwin collections that bundle capabilities for workstation composition.
- Darwin override modules that capture host-specific exceptions when host files must stay thin.

## What does not

- NixOS-only options or Linux service configuration.
- Home Manager-only user-layer policy.
- Host facts such as hostname, hardware details, or machine-local identifiers.
- Secrets material or credentials.

## Naming

- Prefer explicit capability paths (`services/tailscale`, `system/core`, `apps/homebrew`).
- Keep collection names role-focused (`collections/base`, `collections/workstation`).
- Place host exceptions under `overrides/<host>/default.nix` and keep scope narrow.

## Examples

- `services/tailscale/default.nix` for reusable Darwin service policy.
- `collections/workstation/default.nix` for the default Mac workstation bundle.
- `overrides/macbook/default.nix` for macbook-only Darwin exceptions.

## Exception process

1. Put shared macOS policy in a capability module first.
2. If behavior is macbook-only, place it in `overrides/macbook` instead of host sprawl.
3. If a change cannot be cleanly modeled here, document the rationale in the plan summary.
