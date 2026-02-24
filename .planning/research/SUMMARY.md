# Project Research Summary

**Project:** Unified Nix Workstation + VPS Infrastructure
**Domain:** Flake-based Nix infrastructure for one macOS workstation and one Hetzner NixOS VPS
**Researched:** 2026-02-24
**Confidence:** HIGH

## Executive Summary

This is a two-target infrastructure product: one repo acts as the control plane for a MacBook (`nix-darwin`) and a Hetzner VPS (`NixOS`) with deterministic builds, validation, and deployment. The strongest expert pattern is a single pinned flake with strict boundaries: shared modules for true cross-platform policy, platform modules for OS-specific behavior, and thin host files that only compose modules.

The recommended approach is stable-first (`nixos-25.11`), explicit host outputs, integrated Home Manager, one secrets framework (`sops-nix` + `age`), and separate day-0 vs day-2 operations (`nixos-anywhere` + `disko` for bootstrap, `deploy-rs` for steady-state deploys). This gives predictable operations without over-engineering beyond the current two-host scope.

Primary risks are lockfile churn, cross-platform coupling, secrets leakage into evaluation/store, and unsafe remote deploy habits. Mitigation is clear and actionable: targeted flake updates, CI checks for both platforms on every change, strict module layering, runtime-only secret handling, and rollback-tested deployment runbooks.

## Key Findings

### Recommended Stack

Use a flake-native stack with pinned inputs and stable channels as the default path: `nixpkgs/nixos-25.11`, `flake-parts`, `nix-darwin`, Home Manager aligned to `release-25.11`, `sops-nix` + `age`, `deploy-rs`, `nixos-anywhere`, and `disko`. CI should run `nix flake check`, host builds, formatting, and lock hygiene checks; Cachix-backed Actions are the practical baseline.

**Core technologies:**
- **Nix Flakes + pinned `flake.lock`**: deterministic source of truth across laptop, CI, and VPS.
- **`nixpkgs` `nixos-25.11` (stable-first)**: support window and reduced breakage; use `unstable` only for targeted packages.
- **`flake-parts`**: modular flake composition that scales better than ad-hoc glue.
- **`nix-darwin` + Home Manager**: unified declarative model for macOS system and user environment.
- **NixOS modules**: native Linux host definition with reliable rebuild/rollback semantics.
- **`sops-nix` + `age`**: encrypted secrets in git with activation-time decryption across Darwin/NixOS/HM.
- **`nixos-anywhere` + `disko`**: reproducible VPS bootstrap/reprovision path.
- **`deploy-rs`**: safer day-2 remote deployment with rollback protections.
- **GitHub Actions + Cachix**: enforce checks and reduce rebuild latency.

### Expected Features

The MVP should focus on the operational baseline that users expect from this repo type: dual-target outputs, clean shared-vs-host module structure, encrypted secrets, validation gates, and safe deployment flows. Differentiators are valuable, but should be scheduled only after end-to-end reliability is proven.

**Must have (table stakes):**
- Dual-target flake outputs (`darwinConfigurations` and `nixosConfigurations`).
- Shared module layering with explicit host overrides.
- Home Manager integration on both targets.
- Encrypted secrets in repo with runtime decryption.
- Pre-apply validation (`nix flake check`, deploy checks, host evaluations/builds).
- Safe remote VPS deployment with rollback semantics.
- Repeatable VPS bootstrap path.
- Basic CI gate (fmt/lint/check/build) and controlled lock update workflow.

**Should have (competitive):**
- One-command orchestrated apply flow (check/preview/apply).
- Cross-platform contract tests for shared modules.
- Drift/diff reporting before activation.
- Build cache strategy tuned for Darwin + Linux.
- Secret rotation and recovery drill automation.

**Defer (v2+):**
- Ephemeral VM/integration test suite for service/network behavior.
- Full recovery-drill automation cadence.
- Advanced orchestration UX and deep drift tooling.
- Any multi-host fleet abstractions beyond current two-host scope.

### Architecture Approach

Use a single flake control plane with strict ownership boundaries: `flake.nix` wires inputs/outputs, reusable logic lives in `modules/`, host assembly lives in `hosts/`, and checks are codified under `checks/`. Keep hosts thin and modules opinionated; keep bootstrap (install) separate from steady-state deploy operations.

**Major components:**
1. **`flake.nix` control plane** — pins inputs and exposes host/check/deploy artifacts.
2. **`modules/shared`, `modules/darwin`, `modules/nixos`** — reusable policy with explicit OS boundaries.
3. **`hosts/macbook`, `hosts/hetzner-vps`** — final per-host composition and host facts.
4. **`checks/` + CI** — fail-fast determinism and policy gates before any switch/deploy.
5. **Bootstrap/deploy plane** — `nixos-anywhere` + `disko` for day-0, `deploy-rs` for day-2.

### Critical Pitfalls

1. **Uncontrolled lockfile churn** — avoid broad updates; use targeted input updates and dual-platform CI evaluation before merge.
2. **Flake source blind spots (untracked files)** — enforce tracked-file discipline and pre-commit/CI host evaluation.
3. **Secrets leaking into store/evaluation** — ban plaintext secrets and eval-time reads; use runtime secret paths via `sops-nix`.
4. **Darwin/NixOS coupling in shared modules** — enforce `shared`/`darwin`/`nixos` boundaries and separate platform jobs in CI.
5. **Unsafe remote deploy workflow** — standardize evaluate->build->test->switch and regularly rehearse rollback.

## Implications for Roadmap

Based on combined research, build in dependency order and ship reliability gates before aggressive feature depth.

### Phase 1: Foundation Control Plane
**Rationale:** Everything depends on a pinned flake contract and structure conventions.
**Delivers:** Repo skeleton, pinned inputs, host inventory metadata, initial host stubs, lock/update policy.
**Addresses:** Dual-target outputs, controlled update workflow.
**Avoids:** Uncontrolled lock churn, flake source blind spots.

### Phase 2: Shared Baseline + Host Composition
**Rationale:** Module boundaries must be stable before deployment automation.
**Delivers:** `shared` + platform module layers, Home Manager integration, thin host assemblies.
**Addresses:** Shared layering, HM integration, deterministic host builds.
**Avoids:** Cross-platform coupling and over-abstraction.

### Phase 3: Security + Validation Gates
**Rationale:** Secrets and checks must be in place before first meaningful deploy.
**Delivers:** `sops-nix` integration, secret policy, `nix flake check`, deploy checks, CI fmt/lint/build gates.
**Addresses:** Encrypted secrets, pre-apply validation, CI baseline.
**Avoids:** Secret exposure and undetected regression merges.

### Phase 4: VPS Bootstrap + Day-2 Deploy
**Rationale:** Provisioning and operations should be explicit, tested, and rollback-aware.
**Delivers:** `disko` install profile, `nixos-anywhere` runbook, `deploy-rs` topology and safe deploy commands.
**Addresses:** Repeatable bootstrap, safe remote deployment.
**Avoids:** Remote lockout and brittle manual deploy behavior.

### Phase 5: Hardening and Differentiators
**Rationale:** Only after stable operations should advanced automation be added.
**Delivers:** Drift reports, contract tests, cache optimization, rotation/recovery drills, optional orchestration wrapper.
**Addresses:** Competitive differentiators and long-term maintainability.
**Avoids:** Premature complexity and fragile automation.

### Phase Ordering Rationale

- Dependencies are strict: outputs and structure first, then composition, then safety controls, then deploy paths.
- Architecture and pitfalls both indicate security and validation must precede frequent operations.
- Differentiators should follow proven end-to-end deploy and rollback behavior.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 4:** Hetzner-specific bootstrap details (disk layout, networking, rescue flow) and deploy rollback rehearsal design.
- **Phase 5:** Contract test framework choice, drift-diff implementation, and cache topology tuning.

Phases with standard patterns (can skip extra research):
- **Phase 1:** Flake skeleton, input pinning, and lock policy are well documented.
- **Phase 2:** Shared/platform module layering and HM integration patterns are mature.
- **Phase 3:** `sops-nix` + CI check pipeline patterns are established.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Mostly official docs and strong ecosystem consensus for this scope. |
| Features | HIGH | Table stakes and sequencing align across multiple primary docs and repo goals. |
| Architecture | HIGH | Clear, repeatable patterns with explicit dependency chain and boundaries. |
| Pitfalls | HIGH | Risks are concrete, frequently observed, and include practical mitigation paths. |

**Overall confidence:** HIGH

### Gaps to Address

- **Hetzner host specifics:** Final disk/network assumptions need environment validation before irreversible install steps.
- **CI cost posture:** Decide when macOS builds are required on every PR vs required on protected branches.
- **Secret key bootstrap ownership:** Clarify initial `age` key distribution/rotation process between laptop and VPS.
- **Rollback drill SLO:** Define measurable recovery targets and drill cadence for operational confidence.

## Sources

### Primary (HIGH confidence)
- https://nixos.org/blog/announcements/2025/nixos-2511/ — stable baseline and lifecycle context.
- https://channels.nixos.org/nixos-25.11 — channel/status validation.
- https://github.com/nix-darwin/nix-darwin — macOS declarative management model.
- https://nix-community.github.io/home-manager/ — HM integration and `useGlobalPkgs` guidance.
- https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-check — evaluation/check semantics.
- https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-update — lock update workflow.
- https://github.com/Mic92/sops-nix — runtime decryption and cross-platform secret integration.
- https://github.com/serokell/deploy-rs — deployment checks and rollback safety model.
- https://github.com/nix-community/nixos-anywhere — unattended remote install baseline.
- https://github.com/nix-community/disko — declarative disk provisioning.

### Secondary (MEDIUM confidence)
- https://github.com/hercules-ci/flake-parts — modular flake composition strategy.
- https://github.com/cachix/install-nix-action — CI installation baseline.
- https://github.com/cachix/cachix-action — cache integration for build performance.
- https://github.com/DeterminateSystems/flake-checker — lock staleness checks.
- https://github.com/zhaofengli/colmena — comparison point for deployment scope decisions.
- https://mynixos.com/nixpkgs/option/system.stateVersion — option semantics reference.

### Tertiary (LOW confidence)
- None identified.

---
*Research completed: 2026-02-24*
*Ready for roadmap: yes*
