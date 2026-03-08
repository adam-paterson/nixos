# Feature Landscape

**Domain:** Managing one MacBook workstation and one Hetzner NixOS VPS from a single flake-based Nix repo
**Researched:** 2026-02-24

## Table Stakes

Features users expect. Missing = repo feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Dual-target flake outputs (`darwinConfigurations` + `nixosConfigurations`) | Core promise is one repo driving macOS and NixOS deterministically | Med | Baseline contract for this project type; align shared `nixpkgs` input, expose host outputs explicitly |
| Shared module layering with host-specific overrides | Prevents drift while keeping Mac/VPS differences explicit | Med | Common modules for users/packages/policies; host modules for hardware/network/service differences |
| Home Manager integration across both targets | Declarative user-level config is expected in modern Nix repos | Med | Prefer integrated HM module usage for both nix-darwin and NixOS to keep user env reproducible |
| Encrypted secrets committed to repo (sops-nix or agenix) | Secret-in-git (encrypted) is standard pattern for reproducible infra repos | Med | Must avoid cleartext and runtime `builtins.readFile` of decrypted secret paths |
| Pre-apply validation (`nix flake check` + config/deploy checks) | Determinism claim requires failing fast before any switch/deploy | Low | At minimum evaluate all flake outputs and run deploy schema checks |
| Safe remote deployment with rollback semantics | VPS changes need recovery when SSH/network config breaks | Med | deploy-rs `autoRollback` + `magicRollback` are directly aligned to this need |
| Repeatable VPS bootstrap path (fresh host install) | Greenfield infra repo is incomplete without day-0 provisioning story | High | nixos-anywhere + disko is common path for unattended Hetzner provisioning |
| Basic CI gate for Nix formatting/lint/checks | Expected collaboration quality baseline even for single-owner repos | Low | Run formatter/lint/check commands in CI and block broken merges |
| Controlled flake input update workflow | Lockfile discipline is required to keep builds reproducible over time | Low | Use explicit `nix flake update` cadence and review update diffs |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| One-command orchestration for "laptop switch + VPS deploy" with previews | Makes ops feel productized; reduces context switching and human error | Med | Wrapper command that runs checks, previews impacted nodes, then applies in order |
| Contract tests for shared modules on both Darwin and Linux | Catches cross-platform regressions before they reach either target | High | Build test fixtures for both host types and assert expected option outcomes |
| Ephemeral VM/integration testing for VPS service modules | Raises confidence for networking/service changes without touching production | High | Add NixOS VM tests for critical services and firewall assumptions |
| Automated drift/diff reports between current and target generations | Improves change review quality and rollback confidence | Med | Emit human-readable diffs before activation/deployment |
| Secret rotation workflow integrated with repo ops | Moves from "encrypted secrets exist" to "secrets lifecycle is managed" | Med | Key rotation runbooks + periodic rekey checks |
| Build cache strategy (remote cache + fallback) optimized for Mac + VPS | Speeds iteration and reduces repeated local compilation pain | Med | Especially valuable on macOS where rebuild latency is noticeable |
| Recovery drill automation (rebuild VPS from zero with same repo) | Proves infra is actually reproducible, not just declarative on paper | High | Periodic dry-run or disposable-host rebuild exercises |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Premature multi-host orchestration (roles, fleets, env matrix) | Violates current scope and adds abstraction tax before reliability is proven | Keep design explicitly two-target first; add scaling primitives only after stable operations |
| Running multiple deployment systems in parallel (e.g., deploy-rs + Colmena + ad-hoc SSH scripts) | Compounds failure modes and operator confusion | Pick one deployment path for VPS and codify it end-to-end |
| Storing or materializing plaintext secrets in repo/store | Direct security risk; can leak via world-readable Nix store patterns | Keep only encrypted secret files in git and decrypt at activation runtime |
| Heavy meta-framework abstractions on day one | Makes repo inspirational-looking but hard to debug/change | Prefer explicit modules with minimal indirection; abstract only repeated patterns |
| Auto-apply infra changes on every push to default branch | Too risky for workstation + VPS without staged validation/approval | Require checks + explicit operator-triggered apply/deploy step |
| Imperative drift via manual edits/homebrew-first workflows | Breaks determinism and makes repo untrustworthy as source of truth | Route system changes through Nix modules first; document any unavoidable exceptions |
| Frequent broad lockfile churn without scoped updates | Increases breakage surface and makes regressions harder to isolate | Update targeted inputs with review notes and rollback plan |

## Feature Dependencies

```text
Dual-target flake outputs -> Shared module layering
Dual-target flake outputs -> Home Manager integration

Shared module layering -> Pre-apply validation
Home Manager integration -> Pre-apply validation

Encrypted secrets in repo -> Safe remote deployment
Encrypted secrets in repo -> Repeatable VPS bootstrap

Repeatable VPS bootstrap -> Safe remote deployment
Pre-apply validation -> Safe remote deployment

Controlled flake update workflow -> Basic CI gate
Basic CI gate -> One-command orchestration

Safe remote deployment -> Drift/diff reports
Safe remote deployment -> Recovery drill automation
```

## MVP Recommendation

Prioritize:
1. Dual-target flake outputs with clean shared/host module boundaries
2. Pre-apply validation + CI gate (`nix flake check`, formatting/lint, deploy checks)
3. Safe VPS deployment with rollback plus encrypted secret management

Defer: Ephemeral VM/integration test suite: high setup cost for greenfield; add after first stable end-to-end deployments.

## Sources

- Nix manual: `nix flake check` (evaluation/build checks) - https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-check (HIGH)
- Nix manual: `nix flake update` (lockfile update workflow) - https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-update (HIGH)
- nix-darwin README (flake-first Darwin management) - https://raw.githubusercontent.com/nix-darwin/nix-darwin/master/README.md (HIGH)
- Home Manager README (NixOS + nix-darwin module integration) - https://raw.githubusercontent.com/nix-community/home-manager/master/README.md (HIGH)
- deploy-rs README (deploy checks, auto/magic rollback) - https://raw.githubusercontent.com/serokell/deploy-rs/master/README.md (HIGH)
- sops-nix README (encrypted-in-git secrets, CI friendliness, activation-time decryption, limitations) - https://raw.githubusercontent.com/Mic92/sops-nix/master/README.md (HIGH)
- agenix README (encrypted secrets, explicit anti-pattern around `builtins.readFile`) - https://raw.githubusercontent.com/ryantm/agenix/master/README.md (HIGH)
- nixos-anywhere README (single-command unattended remote install) - https://raw.githubusercontent.com/numtide/nixos-anywhere/main/README.md (HIGH)
- disko README (declarative partitioning for repeatable installs) - https://raw.githubusercontent.com/nix-community/disko/master/README.md (HIGH)
- Colmena README (alternative deployment tool, useful for anti-feature decision on tool sprawl) - https://raw.githubusercontent.com/zhaofengli/colmena/main/README.md (MEDIUM)
- git-hooks.nix README (Nix-native lint/format/check integration for dev + CI) - https://raw.githubusercontent.com/cachix/git-hooks.nix/master/README.md (MEDIUM)
