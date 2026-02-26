# Roadmap: Unified Nix Workstation + VPS Infrastructure

## Overview

This roadmap delivers a single deterministic control plane for one MacBook and one Hetzner VPS by sequencing work from foundation contracts to operational safety. Each phase completes a user-verifiable capability and maps every v1 requirement exactly once.

## Phases

- [x] **Phase 1: Flake Control Plane** - Establish deterministic dual-target outputs and pinned dependency behavior. (completed 2026-02-24)
- [x] **Phase 2: Modular Repository Architecture** - Enforce shared/platform module boundaries and thin host composition. (completed 2026-02-24)
- [x] **Phase 3: Cross-Host User Environment** - Apply a unified Home Manager user layer on both targets. (completed 2026-02-24)
- [x] **Phase 4: Secrets-Safe Configuration** - Ensure encrypted-only secret handling with runtime decryption. (completed 2026-02-25)
- [x] **Phase 5: Validation and Change Gates** - Add pre-apply validation, CI quality gates, and controlled input updates. (completed 2026-02-26)
- [ ] **Phase 6: Repeatable Deployment Lifecycle** - Deliver rollback-capable VPS operations and repeatable workstation applies.
- [x] **Phase 7: Secrets Gap Closure** - Close audit-identified secrets blockers and re-establish milestone security guarantees. (completed 2026-02-26)

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
**Plans**: 2 plans
Plans:
- [x] 03-cross-host-user-environment/03-01-PLAN.md - Normalize shared Home Manager user baseline and explicit host override boundaries for macbook and aurora. (completed 2026-02-24)
- [x] 03-cross-host-user-environment/03-02-PLAN.md - Define canonical cross-host Home Manager apply commands and prove both user targets evaluate/build through one workflow contract. (completed 2026-02-24)

### Phase 4: Secrets-Safe Configuration
**Goal**: Users can operate both targets without exposing plaintext secrets in repo or Nix store paths.
**Depends on**: Phase 3
**Requirements**: SECR-01, SECR-02
**Success Criteria** (what must be TRUE):
  1. User can store encrypted secrets in git while avoiding plaintext secret files in tracked configuration.
  2. User can apply or deploy configurations with secrets decrypted only at activation/deploy time.
  3. User can run evaluation and build workflows without plaintext secrets entering Nix evaluation paths or store artifacts.
**Plans**: 4 plans
Plans:
- [x] 04-secrets-safe-configuration/04-01-PLAN.md - Add encrypted secret artifact foundations with `sops-nix` input wiring, SOPS policy rules, and shared plus host-scoped secret files. (completed 2026-02-25)
- [x] 04-secrets-safe-configuration/04-02-PLAN.md - Wire runtime-only decryption and secret path consumption across NixOS, darwin, and Home Manager with host-scoped hard-fail behavior. (completed 2026-02-25)
- [x] 04-secrets-safe-configuration/04-03-PLAN.md - Enforce plaintext leak guardrails in pre-commit and CI while documenting canonical 1Password-centered secret workflows and mock-safe checks. (completed 2026-02-25)
- [x] 04-secrets-safe-configuration/04-04-PLAN.md - Superseded and closed by Phase 7 Plans 07-01 and 07-02; reconciliation evidence captured in `04-04-SUMMARY.md`. (closed 2026-02-26)

### Phase 5: Validation and Change Gates
**Goal**: Users can verify safety and determinism before activation or deployment.
**Depends on**: Phase 4
**Requirements**: VALD-01, VALD-02, VALD-03
**Success Criteria** (what must be TRUE):
  1. User can run `nix flake check` as a reliable pre-apply integrity gate.
  2. User can rely on CI checks (format/lint/check/build) to block unsafe changes from merging.
  3. User can update flake inputs through a controlled process that produces reviewable `flake.lock` diffs.
**Plans**: 3 plans
Plans:
- [x] 05-validation-and-change-gates/05-01-PLAN.md - Establish one canonical local pre-apply validation contract that includes `nix flake check`, host eval, and host dry-build checks. (completed 2026-02-26)
- [x] 05-validation-and-change-gates/05-02-PLAN.md - Harden `Nix Checks` into an explicit merge-blocking CI gate with documented enforcement verification and build-depth coverage. (completed 2026-02-26)
- [x] 05-validation-and-change-gates/05-03-PLAN.md - Enforce controlled lockfile update governance with scoped intent, review checklist, and PR-level lock diff accountability. (completed 2026-02-26)

### Phase 6: Repeatable Deployment Lifecycle
**Goal**: Users can bootstrap, update, and recover both managed targets through repeatable repository-defined workflows.
**Depends on**: Phase 5
**Requirements**: DEPL-01, DEPL-02, DEPL-03
**Success Criteria** (what must be TRUE):
  1. User can bootstrap or reprovision the Hetzner VPS from repository-defined configuration.
  2. User can deploy VPS updates with a rollback-capable workflow.
  3. User can apply workstation updates using repository-defined commands with repeatable results.
**Plans**: 3 plans
Plans:
- [ ] 06-repeatable-deployment-lifecycle/06-01-PLAN.md - Establish deterministic aurora bootstrap/reprovision contract with explicit hardware assumptions, bootstrap wrappers, and rehearsal evidence capture.
- [ ] 06-repeatable-deployment-lifecycle/06-02-PLAN.md - Harden aurora deploy workflow and codify rollback-capable deploy procedures with verification evidence.
- [ ] 06-repeatable-deployment-lifecycle/06-03-PLAN.md - Define authoritative macbook apply/recovery lifecycle using repository-defined commands and documented rollback paths.

### Phase 7: Secrets Gap Closure
**Goal**: Users can close Phase 4 audit blockers so secrets are runtime-only and milestone security guarantees are restored.
**Depends on**: Phase 4
**Requirements**: SECR-01, SECR-02
**Gap Closure:** Closes gaps from `.planning/v1.0-v1.0-MILESTONE-AUDIT.md` for unsatisfied requirements, cross-phase integration, and broken aurora apply flow.
**Success Criteria** (what must be TRUE):
  1. User can remove plaintext OpenClaw token literals from tracked Nix configuration and consume runtime secret paths instead.
  2. User can verify `SECR-01` and `SECR-02` as satisfied in re-verification evidence.
  3. User can run a full-repo secret-scan signoff path for milestone closure in addition to changed-file guardrails.
**Plans**: 3 plans
Plans:
- [x] 07-secrets-gap-closure/07-01-PLAN.md - Implement runtime-only OpenClaw token wiring and capture raw implementation evidence without authoritative verification updates. (completed 2026-02-26)
- [x] 07-secrets-gap-closure/07-02-PLAN.md - Implement full-repo secret-scan signoff path with explicit CI triggers (`push` to `main` and `workflow_dispatch`) invoking `SECRETS_SCAN_SCOPE=full`. (completed 2026-02-26)
- [x] 07-secrets-gap-closure/07-03-PLAN.md - Perform authoritative verification and milestone audit reconciliation, including explicit `04-04` superseded disposition and traceability synchronization. (completed 2026-02-26)

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Flake Control Plane | 2/2 | Complete    | 2026-02-24 |
| 2. Modular Repository Architecture | 3/3 | Complete | 2026-02-24 |
| 3. Cross-Host User Environment | 2/2 | Complete    | 2026-02-24 |
| 4. Secrets-Safe Configuration | 4/4 | Complete (04-04 superseded by Phase 7 closure path) | 2026-02-26 |
| 5. Validation and Change Gates | 3/3 | Complete    | 2026-02-26 |
| 6. Repeatable Deployment Lifecycle | 0/3 | Not started | - |
| 7. Secrets Gap Closure | 3/3 | Complete | 2026-02-26 |
