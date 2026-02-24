# Homes Composition Contract

## Purpose

`src/homes/` defines thin Home Manager composition per user@host target.

## What goes here

- Host-local user facts and small environment differences.
- Imports and toggles that compose reusable modules from `src/modules/home/`.
- User@host specific wiring that cannot be shared safely.

## What does not

- Reusable user policy that belongs in `src/modules/home/`.
- System-level Darwin or NixOS behavior.
- Broad feature definitions duplicated across multiple user@host targets.

## Naming

- Use explicit `user@host` directory names under architecture roots.
- Keep each `default.nix` focused on composition and host-local data.
- Keep toggle names aligned with module capabilities.

## Examples

- Good:
  - enabling shared collections (`cosmos.collections.home.dev.enable = true;`)
  - setting host-local user path exceptions.
- Not good:
  - implementing full app/tool policy directly in `src/homes/...`.

## Exception process

1. Put reusable behavior in `src/modules/home/` first.
2. Keep `src/homes/...` files to host-local user data and toggle composition.
3. If an exception is unavoidable, document why it cannot be represented as a reusable module.
