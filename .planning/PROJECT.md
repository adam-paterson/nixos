# Unified Nix Workstation + VPS Infrastructure

## What This Is

This project defines and operates one MacBook workstation and one Hetzner VPS running NixOS from a single repository. It aims to make local development, system configuration, testing, and deployment deterministic and repeatable. The primary audience is the repository owner, with the repo also serving as a clean reference architecture for similar Nix projects.

## Core Value

One repository can reliably produce, test, and deploy deterministic system states for both the MacBook and the Hetzner NixOS VPS.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Deterministic configuration builds for both macOS and NixOS targets from this repository
- [ ] Clear, maintainable project structure that is easy to navigate and extend
- [ ] Reliable testing and validation pipeline for configuration changes before deployment
- [ ] Safe, repeatable deployment flow for Hetzner VPS and local workstation updates
- [ ] Stronger consistency guarantees around key shared modules and environment definitions

### Out of Scope

- Broad infrastructure expansion beyond current MacBook + single Hetzner VPS scope — focus is quality and reliability of current targets first
- Rewriting everything from scratch — preserve useful existing work and improve structure incrementally

## Context

Some foundation work is already present in the repository, but it needs cleanup and stronger architectural consistency. The user wants the project to feel inspirational as an example of how to structure a Nix codebase while still being practical for daily operations. Testing and deployment are currently the biggest hardening targets.

## Constraints

- **Tech stack**: Nix-based configuration management (flake-driven) — keep environment definitions declarative and reproducible
- **Scope**: Two managed environments (MacBook + Hetzner NixOS VPS) — avoid premature multi-host complexity
- **Reliability**: Determinism first — favor predictable builds/deployments over convenience shortcuts
- **Architecture quality**: Clean structure is a core outcome — organization must remain understandable as project grows

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Manage both MacBook and Hetzner VPS from one repository | Single source of truth reduces drift and operational overhead | — Pending |
| Prioritize deterministic workflows and architecture cleanup before adding new capabilities | Stability and clarity are prerequisites for confident iteration | — Pending |
| Invest in testing and deployment hardening as first-class work | Prevent regressions and make changes safe to ship | — Pending |

---
*Last updated: 2026-02-24 after initialization*
