# Roadmap: Unified Nix Workstation + VPS Infrastructure

## Overview

This roadmap delivers a single deterministic control plane for one MacBook and one Hetzner VPS by sequencing work from foundation contracts to operational safety. Each phase completes a user-verifiable capability and maps every v1 requirement exactly once.

## Phases

- [x] **Phase 1: Flake Control Plane** - Establish deterministic dual-target outputs and pinned dependency behavior. (completed 2026-02-24)
- [ ] **Phase 2: Modular Repository Architecture** - Enforce shared/platform module boundaries and thin host composition.
- [ ] **Phase 3: Cross-Host User Environment** - Apply a unified Home Manager user layer on both targets.
- [ ] **Phase 4: Secrets-Safe Configuration** - Ensure encrypted-only secret handling with runtime decryption.
- [ ] **Phase 5: Validation and Change Gates** - Add pre-apply validation, CI quality gates, and controlled input updates.
- [ ] **Phase 6: Repeatable Deployment Lifecycle** - Deliver rollback-capable VPS operations and repeatable workstation applies.

## Phase Details

### Phase 1: Flake Control Plane
**Goal**: Users can deterministically evaluate and build both managed targets from one pinned flake.
**Depends on**: Nothing (first phase)
**Requirements**: CORE-01, CORE-02, CORE-03
**Success Criteria** (what must be TRUE):
  1. User can build both `darwinConfigurations` and `nixosConfigurations` from the same flake entrypoints.
  2. User can reproduce the same input revisions from `flake.lock` across repeated runs and environments.
  3. User can evaluate all configured hosts without ad hoc per-host imperative setup.
**Plans**: 2 plans
Plans:
- [ ] 01-flake-control-plane/01-01-PLAN.md - Enforce a host-matrix eval and dry-build contract for all Darwin and NixOS flake targets.
- [ ] 01-flake-control-plane/01-02-PLAN.md - Define lockfile-first workflow and executable lock verification/update commands.

### Phase 2: Modular Repository Architecture
**Goal**: Users can maintain and extend the repo through clear, reusable module composition boundaries.
**Depends on**: Phase 1
**Requirements**: STRU-01, STRU-02, STRU-03
**Success Criteria** (what must be TRUE):
  1. User can place shared policy in reusable modules with explicit Darwin vs NixOS separation.
  2. User can keep host definitions thin by composing modules instead of embedding host-specific policy logic.
  3. User can quickly find where to add or modify logic using documented architecture conventions.
**Plans**: 3 plans
Plans:
- [x] 02-modular-repository-architecture/02-01-PLAN.md - Refactor Darwin host composition to thin host plus dedicated macbook override boundaries. (completed 2026-02-24)
- [x] 02-modular-repository-architecture/02-02-PLAN.md - Refactor NixOS host composition to thin host plus dedicated aurora override boundaries. (completed 2026-02-24)
- [x] 02-modular-repository-architecture/02-03-PLAN.md - Add local architecture contract READMEs and root navigation links for fast structure discovery. (completed 2026-02-24)

### Phase 3: Cross-Host User Environment
**Goal**: Users can manage one consistent user environment layer across workstation and VPS.
**Depends on**: Phase 2
**Requirements**: HOME-01
**Success Criteria** (what must be TRUE):
  1. User can apply Home Manager-managed configuration on both MacBook and VPS targets.
  2. User can keep core user-level environment settings consistent across both targets from repository-defined config.
**Plans**: TBD

### Phase 4: Secrets-Safe Configuration
**Goal**: Users can operate both targets without exposing plaintext secrets in repo or Nix store paths.
**Depends on**: Phase 3
**Requirements**: SECR-01, SECR-02
**Success Criteria** (what must be TRUE):
  1. User can store encrypted secrets in git while avoiding plaintext secret files in tracked configuration.
  2. User can apply or deploy configurations with secrets decrypted only at activation/deploy time.
  3. User can run evaluation and build workflows without plaintext secrets entering Nix evaluation paths or store artifacts.
**Plans**: TBD

### Phase 5: Validation and Change Gates
**Goal**: Users can verify safety and determinism before activation or deployment.
**Depends on**: Phase 4
**Requirements**: VALD-01, VALD-02, VALD-03
**Success Criteria** (what must be TRUE):
  1. User can run `nix flake check` as a reliable pre-apply integrity gate.
  2. User can rely on CI checks (format/lint/check/build) to block unsafe changes from merging.
  3. User can update flake inputs through a controlled process that produces reviewable `flake.lock` diffs.
**Plans**: TBD

### Phase 6: Repeatable Deployment Lifecycle
**Goal**: Users can bootstrap, update, and recover both managed targets through repeatable repository-defined workflows.
**Depends on**: Phase 5
**Requirements**: DEPL-01, DEPL-02, DEPL-03
**Success Criteria** (what must be TRUE):
  1. User can bootstrap or reprovision the Hetzner VPS from repository-defined configuration.
  2. User can deploy VPS updates with a rollback-capable workflow.
  3. User can apply workstation updates using repository-defined commands with repeatable results.
**Plans**: TBD

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Flake Control Plane | 0/2 | Complete    | 2026-02-24 |
| 2. Modular Repository Architecture | 3/3 | Complete | 2026-02-24 |
| 3. Cross-Host User Environment | 0/TBD | Not started | - |
| 4. Secrets-Safe Configuration | 0/TBD | Not started | - |
| 5. Validation and Change Gates | 0/TBD | Not started | - |
| 6. Repeatable Deployment Lifecycle | 0/TBD | Not started | - |
