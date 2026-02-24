# Home Modules Contract

## Purpose

`src/modules/home/` contains reusable Home Manager modules for cross-host user environment composition.

## What goes here

- User-layer capability modules (`apps`, `dev`, `prompts`, `security`).
- Home collections that compose common user profiles (`base`, `cli`, `desktop`, `dev`).
- Cross-host user policy that should apply consistently on macOS and Linux unless explicitly scoped.

## What does not

- System-level Darwin or NixOS policy.
- Host-only user facts (for example machine-local paths tied to one host).
- Secret payloads.
- Host composition wiring that belongs in `src/homes/...`.

## Naming

- Use tool or capability-specific names (`dev/neovim`, `security/onepassword-cli`).
- Keep collection names outcome-oriented (`collections/dev`, `collections/desktop`).
- Prefer explicit names over generic buckets.

## Examples

- `dev/git/default.nix` for shared git behavior.
- `prompts/spaceship/default.nix` for shell prompt policy.
- `collections/desktop/default.nix` for user desktop bundle composition.

## Exception process

1. Start with reusable Home Manager capability placement.
2. If behavior is host-only, keep the exception in `src/homes/...` and keep it thin.
3. If uncertainty remains, document the decision in the plan summary and update local docs if needed.
