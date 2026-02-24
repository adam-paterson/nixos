# Requirements: Unified Nix Workstation + VPS Infrastructure

**Defined:** 2026-02-24
**Core Value:** One repository can reliably produce, test, and deploy deterministic system states for both the MacBook and the Hetzner NixOS VPS.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Topology

- [ ] **CORE-01**: User can build both `darwinConfigurations` and `nixosConfigurations` from one flake
- [ ] **CORE-02**: User can reproduce the same dependency graph from a pinned `flake.lock`
- [ ] **CORE-03**: User can evaluate all configured hosts without manual per-host imperative setup

### Project Structure

- [ ] **STRU-01**: User can organize shared logic in reusable modules with explicit Darwin vs NixOS boundaries
- [ ] **STRU-02**: User can keep host definitions thin, with host files composing modules instead of embedding policy
- [ ] **STRU-03**: User can navigate repository structure quickly using documented architecture conventions

### User Environment

- [ ] **HOME-01**: User can apply Home Manager-managed user configuration on both MacBook and VPS targets

### Secrets and Security

- [ ] **SECR-01**: User can store only encrypted secrets in git and decrypt them at activation/deploy time
- [ ] **SECR-02**: User can apply configurations without exposing plaintext secrets in Nix evaluation paths or store artifacts

### Validation and Quality Gates

- [ ] **VALD-01**: User can run `nix flake check` to validate repository integrity before apply/deploy
- [ ] **VALD-02**: User can run CI checks (format/lint/check/build) that block unsafe changes from merging
- [ ] **VALD-03**: User can update flake inputs through a controlled workflow with reviewable lockfile diffs

### Deployment and Lifecycle

- [ ] **DEPL-01**: User can deploy VPS changes through a rollback-capable workflow
- [ ] **DEPL-02**: User can bootstrap or reprovision the Hetzner VPS from repository-defined configuration
- [ ] **DEPL-03**: User can apply workstation updates from repository-defined commands with repeatable results

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Advanced Automation

- **AUTO-01**: User can run a single orchestration command that previews and applies MacBook + VPS updates in safe order
- **AUTO-02**: User can generate automated drift/diff reports before activation or deployment

### Advanced Testing and Resilience

- **TEST-01**: User can run cross-platform contract tests validating shared module behavior on Darwin and NixOS
- **TEST-02**: User can run ephemeral VM/integration tests for critical VPS networking and services
- **TEST-03**: User can run scheduled recovery drills that verify rollback and rebuild playbooks

### Operational Maturity

- **SECR-03**: User can rotate secrets with documented and repeatable key lifecycle workflows
- **OPS-01**: User can use optimized remote cache strategy for faster cross-platform rebuild cycles

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Multi-host fleet abstractions beyond current MacBook + single VPS | Violates current scope and adds complexity before baseline reliability is proven |
| Multiple deployment systems in parallel | Increases operator confusion and failure modes; one canonical deployment path is required |
| Plaintext secret storage or eval-time secret loading | Breaks security guarantees and can leak via world-readable store paths |
| Fully automatic apply/deploy on every push | Too risky without explicit operator-controlled execution and rollback checks |
| Full repository rewrite from scratch | Existing useful work should be preserved and incrementally improved |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Pending |
| CORE-02 | Phase 1 | Pending |
| CORE-03 | Phase 1 | Pending |
| STRU-01 | Phase 2 | Pending |
| STRU-02 | Phase 2 | Pending |
| STRU-03 | Phase 2 | Pending |
| HOME-01 | Phase 3 | Pending |
| SECR-01 | Phase 4 | Pending |
| SECR-02 | Phase 4 | Pending |
| VALD-01 | Phase 5 | Pending |
| VALD-02 | Phase 5 | Pending |
| VALD-03 | Phase 5 | Pending |
| DEPL-01 | Phase 6 | Pending |
| DEPL-02 | Phase 6 | Pending |
| DEPL-03 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 15 total
- Mapped to phases: 15
- Unmapped: 0

---
*Requirements defined: 2026-02-24*
*Last updated: 2026-02-24 after roadmap mapping*
