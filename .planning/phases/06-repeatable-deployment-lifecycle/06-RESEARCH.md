# Phase 6: Repeatable Deployment Lifecycle - Research

**Researched:** 2026-02-26
**Domain:** Deterministic bootstrap, update, and rollback lifecycle for NixOS VPS (`aurora`) and nix-darwin workstation (`macbook`)
**Confidence:** MEDIUM-HIGH

<user_constraints>
## User Constraints

No `*-CONTEXT.md` exists for this phase. Use roadmap and requirements as constraints.

### Locked Decisions
- Phase goal is repository-defined workflows for bootstrap, update, and recovery.
- Scope includes both managed targets: `aurora` (Hetzner VPS) and `macbook` (nix-darwin).
- Phase must satisfy `DEPL-01`, `DEPL-02`, and `DEPL-03`.

### Claude's Discretion
- Define the canonical deployment command surfaces and sequencing.
- Define rollback/recovery mechanics and operator verification evidence.
- Recommend bootstrap approach for Hetzner reprovisioning that fits current repository architecture.

### Deferred Ideas (OUT OF SCOPE)
- Full fleet abstractions and multi-host orchestration beyond `aurora` + `macbook`.
- Fully automatic unattended apply/deploy on every push.
- Advanced integration/resilience drill automation (v2 TEST requirements).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DEPL-01 | User can deploy VPS changes through a rollback-capable workflow | Use `nixos-rebuild switch --flake .#aurora` as canonical apply surface and define explicit rollback path via `nixos-rebuild switch --rollback` plus generation evidence; align remote activation with `.github/workflows/deploy-aurora.yml` ref-based dispatch path. |
| DEPL-02 | User can bootstrap or reprovision the Hetzner VPS from repository-defined configuration | Add a repo-defined bootstrap runbook and command surface (recommended: `nixos-anywhere` + host hardware/disks contract) so a fresh Hetzner VM can be rebuilt from this repo without ad hoc manual steps. |
| DEPL-03 | User can apply workstation updates from repository-defined commands with repeatable results | Standardize `just pre-apply-check` + machine/user scoped apply commands (`nix run nix-darwin -- switch --flake .#macbook`, `just home-switch-macbook`) with consistent verification outputs and rollback decision path. |
</phase_requirements>

## Summary

Phase 6 should formalize an existing but partially implicit deployment lifecycle into one explicit operator contract. This repository already has strong prerequisites in place: deterministic flake outputs, canonical pre-apply gates (`just pre-apply-check`), CI/cache/deploy workflow chaining (`nix-checks.yml` -> `nix-cache.yml` -> `deploy-aurora.yml`), and command wrappers in `Justfile` for host applies. The missing piece is not tooling depth; it is lifecycle completeness and documented recovery behavior.

Current state is asymmetric. `DEPL-01` and `DEPL-03` are close because update workflows exist for both hosts, but rollback and recovery are not codified end-to-end. `DEPL-02` is the largest gap: there is no repository-defined, one-command VPS provisioning workflow today (no `nixos-anywhere`/`disko` automation and hardware placeholders remain in `src/systems/x86_64-linux/aurora/hardware/default.nix`). The phase plan should close this by introducing a deterministic bootstrap path and acceptance evidence from a reprovision rehearsal.

For planning, treat this phase as operational contract hardening around three lifecycle lanes: bootstrap, steady-state updates, and rollback/recovery. Keep command surfaces small (`just`-first), ensure every lane is verifiable with explicit commands, and avoid introducing a second deployment system beyond the existing Cachix activation path.

**Primary recommendation:** Keep `Justfile` as the operator interface, add one canonical Hetzner reprovision workflow, and define explicit rollback evidence for both hosts so every lifecycle action is repository-defined and repeatable.

## Project Skill Considerations

Repository-local skill inventory under `.agents/skills/` currently contains `using-git-worktrees`.

- Relevance to this phase: execution hygiene only (isolated implementation work), not deployment architecture.
- Planning impact: no additional deployment primitives; keep lifecycle design based on existing repo command/workflow surfaces.

## Standard Stack

### Core
| Component | Current State | Purpose | Why Standard Here |
|-----------|---------------|---------|-------------------|
| `Justfile` command surface | Implemented | Operator-facing lifecycle commands | Already established canonical interface for checks, secrets, apply, and host/user workflows. |
| `nixos-rebuild` + flake target (`.#aurora`) | Implemented | VPS apply and rollback-capable NixOS generation management | Native NixOS deployment path; aligns with requirement for rollback-capable VPS updates. |
| `nix-darwin` switch (`.#macbook`) | Implemented | Workstation machine-level apply | Existing repo contract for macOS system updates. |
| GitHub Actions chain (`nix-checks` -> `nix-cache` -> `deploy-aurora`) | Implemented | Repeatable CI-validated build+activation flow for `aurora` | Already gives deterministic ref-based deploy activation from cache artifacts. |
| Cachix Deploy activation | Implemented in workflow and README | Remote activation against named agent | Preserves reproducible remote activation path without SSH imperative drift. |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `just pre-apply-check` | Mandatory safety gate before any switch/deploy | Always before local apply, remote deploy, or recovery action. |
| `just secrets-auth-preflight` + `secrets-apply/deploy-*` | Runtime secret auth enforcement at apply/deploy time | Required for secret-dependent `macbook`/`aurora` operations. |
| `nix-cache.yml` build targets | Produces cache artifacts for both platforms | Use for CI-driven deploy and rollback-to-ref workflows. |
| Host hardware module (`src/systems/x86_64-linux/aurora/hardware/default.nix`) | VPS boot/filesystem hardware contract | Must be finalized during bootstrap/reprovision design. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Keep manual VPS reinstall runbook only | Repository-managed provisioning (`nixos-anywhere`) | Manual reinstall is brittle and non-repeatable; provisioning tool adds setup but closes DEPL-02 properly. |
| Direct SSH `nixos-rebuild` as primary deploy path | Cachix agent activation as primary remote path | SSH direct is simple but less reproducible in CI and harder to audit than ref-based workflow activations. |
| Multiple deploy systems in parallel (`deploy-rs`, Colmena, custom scripts) | Keep one canonical deploy lane | Multiple systems violate project out-of-scope policy and increase operator error risk. |

## Lifecycle Architecture Patterns

### Recommended Project Structure (for this phase)
```text
Justfile                                            # Canonical operator entrypoints
.github/workflows/deploy-aurora.yml                # Ref-based remote deploy activation
.github/workflows/nix-cache.yml                    # Cache-producing build matrix
README.md                                           # Operator runbooks and lifecycle docs
src/systems/x86_64-linux/aurora/default.nix         # VPS host composition target
src/systems/x86_64-linux/aurora/hardware/default.nix# VPS hardware/disk facts for reprovision
```

### Pattern 1: Three-Lane Lifecycle Contract (Bootstrap, Update, Recover)
**What:** Define one explicit command path per lane and host, with fixed verification evidence.
**When to use:** For all `aurora` and `macbook` lifecycle operations.
**Why:** Prevents ad hoc command drift and makes DEPL requirements testable.

**Host/lifecycle matrix (recommended):**

| Host | Bootstrap/Reprovision | Update | Rollback/Recovery | Verify |
|------|------------------------|--------|-------------------|--------|
| `aurora` | Add repo-defined provisioning command (recommended `nixos-anywhere`-based) producing host in flake-managed state | `just pre-apply-check` then `just secrets-deploy-aurora` or CI `deploy-aurora` dispatch | `sudo nixos-rebuild switch --rollback` for immediate rollback; CI rollback by dispatching prior known-good `ref` | `nixos-rebuild list-generations`, `systemctl status`, service reachability checks |
| `macbook` | Existing machine assumed provisioned; enforce repo bootstrap prerequisites in docs (`nix`, flake, secrets auth) | `just pre-apply-check` then `just secrets-apply-macbook` (machine) or `just home-switch-macbook` (user only) | Re-apply previous known-good repo revision via same switch command; codify generation-based fallback as an explicit tested command during implementation | `darwin-rebuild` switch output, `just home-build-macbook`, key service/tool smoke checks |

### Pattern 2: Ref-Pinned Deploy and Rollback for Aurora
**What:** Use `deploy-aurora.yml` `workflow_dispatch` `ref` input as deploy selector.
**When to use:** Normal deploys from `main` and rollback to known-good commits.
**Why:** The workflow already supports explicit target ref selection and deterministic cache/system resolution.
**Example:**
```bash
# Validate before remote activation
just pre-apply-check

# Deploy specific known-good ref (manual dispatch in GitHub UI/CLI)
# workflow: Deploy Aurora
# inputs: ref=<commit|tag|branch>, agent_name=aurora
```

### Pattern 3: Scope-Aware Workstation Apply
**What:** Separate user-layer and machine-layer apply paths but keep one preflight gate.
**When to use:** Every `macbook` change.
**Why:** Reduces risk and runtime for user-only changes while preserving deterministic full-system path.
**Example:**
```bash
# Always first
just pre-apply-check

# User-only changes
just home-switch-macbook

# Machine-level changes
just secrets-apply-macbook
```

### Anti-Patterns to Avoid
- Running host applies/deploys without `just pre-apply-check`.
- Maintaining two canonical Aurora deployment paths with different guarantees.
- Treating bootstrap as a one-off manual notebook instead of repository automation.
- Declaring rollback support without tested command evidence per host.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| VPS deployment orchestration | Bespoke deploy shell scripts with custom SSH/state logic | Existing GitHub Actions + Cachix deploy flow | Already implemented, auditable, and tied to validated build outputs. |
| Rollback bookkeeping | Manual notes/spreadsheets of "last good" states | Git refs + generation history (`nixos-rebuild` generations) | Native provenance is deterministic and easier to verify. |
| Bootstrap from scratch | Manual sequence of package installs and copied config edits | Repository-defined provisioning command and host module facts | Eliminates drift and satisfies DEPL-02 repeatability. |
| Workstation update execution | Free-form local command combinations | Fixed `just` wrappers and documented decision tree | Keeps operations repeatable and reviewable. |

**Key insight:** The highest risk is operational inconsistency, not missing Nix primitives. Phase 6 should standardize lifecycle choreography and evidence, not invent new deployment frameworks.

## Common Pitfalls

### Pitfall 1: DEPL-02 Left as Documentation Only
**What goes wrong:** Reprovision depends on tribal/manual steps and cannot be repeated reliably.
**Why it happens:** Existing README includes bootstrap fragments but not a full repo-executable Hetzner provisioning flow.
**How to avoid:** Add a single bootstrap command path, prerequisites, and a reprovision rehearsal checklist with captured outputs.
**Warning signs:** Fresh VPS setup requires ad hoc shell history or one-off edits outside repository state.

### Pitfall 2: "Rollback-Capable" Claimed but Untested
**What goes wrong:** Deploy path exists, but rollback fails under pressure.
**Why it happens:** No explicit rollback drills or verification commands are codified.
**How to avoid:** Add required rollback exercise for both hosts and record evidence in phase acceptance artifacts.
**Warning signs:** Team cannot answer "what exact command do we run right now to recover?" for `aurora` and `macbook`.

### Pitfall 3: Host Hardware Contract Drift
**What goes wrong:** Reprovisioned `aurora` boots with wrong disk/device assumptions.
**Why it happens:** `hardware/default.nix` still contains placeholder filesystem guidance (`/dev/sda1` comment) and environment-specific assumptions.
**How to avoid:** Finalize hardware/disk contract as part of bootstrap automation and verify against Hetzner target profile.
**Warning signs:** Post-provision boot failure or manual filesystem patching after first deploy.

### Pitfall 4: Pre-existing Validation Blockers Prevent Lifecycle Confidence
**What goes wrong:** Deployment contract appears defined, but required preflight fails on unrelated baseline issues.
**Why it happens:** Known state blockers remain (`openclaw` option mismatch and formatting drift).
**How to avoid:** Treat baseline gate cleanliness as Phase 6 entry condition and resolve blockers before acceptance testing.
**Warning signs:** `just pre-apply-check` fails before apply/deploy-specific logic executes.

## Code Examples

### Canonical safety gate before apply/deploy
```bash
# Source: Justfile
just pre-apply-check
```

### Existing host apply commands
```bash
# Source: Justfile
just secrets-apply-macbook
just secrets-deploy-aurora
```

### Existing CI-driven Aurora deploy activation (ref-capable)
```yaml
# Source: .github/workflows/deploy-aurora.yml
on:
  workflow_dispatch:
    inputs:
      ref:
        default: main
      agent_name:
        default: aurora
```

### Existing cache build artifacts feeding deploy lifecycle
```yaml
# Source: .github/workflows/nix-cache.yml
- .#nixosConfigurations.aurora.config.system.build.toplevel
- .#darwinConfigurations.macbook.system
```

## State of the Art (Repo-Specific)

| Prior expectation | Current observed state | Phase 6 implication |
|-------------------|------------------------|---------------------|
| Need deterministic deploy primitives | CI and local apply surfaces are already deterministic and flake-pinned | Build on current surfaces; avoid replacing them. |
| Need rollback-capable VPS deploy | NixOS native rollback exists; workflow supports ref-target deploys | Must codify and test rollback runbook as acceptance evidence. |
| Need reprovision-from-repo | No full in-repo Hetzner bootstrap automation yet | Primary implementation gap for DEPL-02. |
| Need repeatable workstation updates | Canonical commands exist but lifecycle policy is split across docs | Consolidate into one operator lifecycle section with explicit decision points. |

## Open Questions

1. Which bootstrap tool is canonical for Hetzner reprovisioning in this repo?
- What we know: `DEPL-02` needs repo-defined full reprovision; current repo lacks an explicit provisioning tool path.
- What is unclear: whether to adopt `nixos-anywhere` directly, add disk automation, or keep manual install with strict script wrapper.
- Recommendation: choose one canonical tool in Plan 06-01 and codify it end-to-end; prefer `nixos-anywhere` for reproducibility.

2. What is the required rollback SLO and acceptance evidence depth?
- What we know: requirement asks rollback-capable VPS workflow; current docs do not define time-to-recover target or drill cadence.
- What is unclear: minimum evidence needed (single command transcript vs full service recovery checks).
- Recommendation: require at least one rollback drill transcript for `aurora` and one tested macbook recovery path during phase verification.

3. What is the canonical macbook rollback command contract?
- What we know: machine-level apply is `nix run nix-darwin -- switch --flake .#macbook`; previous-ref re-apply is always possible.
- What is unclear: preferred generation rollback command form to document as first-line recovery.
- Recommendation: decide and test one explicit command during implementation, then add it to README + Justfile wrapper for parity with aurora.

## Validation Architecture

This repository's `.planning/config.json` does not define `workflow.nyquist_validation: true`, so no Nyquist-specific validation section is required for this phase research.

## Recommended Plan Slices

1. **Slice A: Hetzner bootstrap/reprovision contract (DEPL-02)**
- Implement one repository-defined provisioning workflow for `aurora` from fresh host to flake-managed system.
- Capture prerequisites (keys/secrets/tokens), command wrappers, and post-bootstrap verification.
- Acceptance: fresh/reprovisioned host reaches managed state using only repository runbook + commands.

2. **Slice B: Aurora update and rollback workflow hardening (DEPL-01)**
- Standardize update path (local + CI dispatch) and codify rollback (`switch --rollback` and/or prior-ref deploy dispatch).
- Add explicit verification checklist (generation list, service health, connectivity).
- Acceptance: operator can deploy forward and rollback using documented commands only.

3. **Slice C: Macbook repeatable apply and recovery workflow (DEPL-03)**
- Consolidate user-vs-system apply decision tree into canonical `just` commands and docs.
- Add one explicit, tested recovery path for workstation regressions.
- Acceptance: repeated applies from clean checkout produce consistent results and recovery path is documented and validated.

## Sources

### Primary (HIGH confidence)
- Repository evidence:
  - `README.md`
  - `Justfile`
  - `.github/workflows/nix-checks.yml`
  - `.github/workflows/nix-cache.yml`
  - `.github/workflows/deploy-aurora.yml`
  - `src/shells/common/default.nix`
  - `src/systems/x86_64-linux/aurora/default.nix`
  - `src/systems/x86_64-linux/aurora/hardware/default.nix`
  - `src/systems/README.md`
  - `src/homes/README.md`
- Workspace state evidence:
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  - `.planning/ROADMAP.md`

### Secondary (MEDIUM confidence)
- NixOS rollback command reference: `https://nixos.wiki/wiki/Nixos-rebuild`
- NixOS provisioning tooling reference (`nixos-anywhere`): `https://github.com/nix-community/nixos-anywhere`

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - derived from existing repository command/workflow surfaces.
- Architecture: MEDIUM-HIGH - lifecycle model is concrete, but bootstrap implementation choice is still open.
- Pitfalls: HIGH - directly evidenced by current docs/state and requirement gaps.

**Research date:** 2026-02-26
**Valid until:** 2026-03-28 (or until deployment workflows/host bootstrap design changes)
