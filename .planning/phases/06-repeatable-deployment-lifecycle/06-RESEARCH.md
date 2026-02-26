# Phase 6: Repeatable Deployment Lifecycle - Research

**Researched:** 2026-02-26
**Domain:** Repository-defined bootstrap, deploy/rollback, and workstation apply lifecycle for `aurora` (NixOS VPS) and `macbook` (nix-darwin)
**Confidence:** HIGH (repo-state), MEDIUM (bootstrap tooling specifics)

<user_constraints>
## User Constraints

No `*-CONTEXT.md` exists for this phase. Constraints are derived from requirements, roadmap, and current phase artifacts.

### Locked Decisions
- Phase 6 must satisfy `DEPL-01`, `DEPL-02`, and `DEPL-03`.
- Scope remains exactly one VPS (`aurora`) and one workstation (`macbook`).
- Workflows must be repository-defined and repeatable, not ad hoc operator memory.
- A rollback-capable VPS path is mandatory.

### Claude's Discretion
- Choose the canonical bootstrap lane for Hetzner reprovisioning and encode it as a repo command surface.
- Define the minimum deploy/rollback evidence required to claim requirement closure.
- Define workstation recovery command contract where current docs are not explicit.

### Deferred Ideas (OUT OF SCOPE)
- Multi-host orchestration frameworks and fleet abstractions.
- Fully unattended apply/deploy-on-push automation.
- Advanced resilience drills and ephemeral integration lab automation (v2 scope).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEPL-01 | rollback-capable VPS deployment | Existing repo already has canonical VPS apply/deploy surfaces (`just secrets-deploy-aurora`, `.github/workflows/deploy-aurora.yml` with `workflow_dispatch.ref`). Planning must add explicit rollback contract and verification evidence (`switch --rollback` + prior-ref redeploy). |
| DEPL-02 | repository-defined Hetzner VPS bootstrap/reprovision | Current repo has no executable bootstrap lane yet; `aurora` hardware contract still carries placeholder root-disk guidance. Planning must add one canonical bootstrap command lane (recommended `nixos-anywhere`), finalize host hardware assumptions, and require bootstrap rehearsal evidence. |
| DEPL-03 | repeatable workstation apply/update path | Repo already has machine/user apply commands and gate (`just pre-apply-check`, `just secrets-apply-macbook`, `just home-switch-macbook`). Planning must formalize decision tree + recovery procedure + verification checklist into one authoritative runbook. |
</phase_requirements>

## Summary

This phase is mostly an operational-contract completion problem, not a tooling-invention problem. The repository already has deterministic foundations: pinned flake workflow, canonical local gate (`just pre-apply-check`), CI build/deploy chain (`Nix Checks` -> `Nix Cache Build` -> `Deploy Aurora`), and host-scoped apply wrappers in `Justfile`. The biggest missing capability is deterministic VPS bootstrap/reprovision from repo-defined commands (`DEPL-02`), followed by codified rollback evidence (`DEPL-01`) and a single authoritative workstation recovery contract (`DEPL-03`).

Planning should assume three lifecycle lanes and keep them distinct: (1) bootstrap/reprovision, (2) steady-state update, (3) rollback/recovery. Each lane needs one canonical entrypoint, one verification checklist, and one evidence artifact. Avoid introducing a second deployment system; keep Cachix deploy and existing `just` surfaces as the primary operator interface.

The highest planning risk is claiming requirement closure with documentation-only intent rather than executable, testable procedures. Phase plans should require dry-run or live rehearsal outputs that demonstrate operators can actually execute bootstrap, forward deploy, and rollback/recovery with repository commands only.

**Primary recommendation:** Plan Phase 6 around hard acceptance evidence per requirement, with `Justfile` as the local control surface and `deploy-aurora.yml` as the canonical remote activation lane.

## Current Repo Baseline (Validated)

### Canonical command surfaces already present
- `just pre-apply-check` runs `fmt-check`, `lint`, `check`, `eval`, `flake-contract`, and `secrets-scan`.
- `just secrets-apply-macbook` uses `nix run nix-darwin -- switch --flake .#macbook`.
- `just secrets-deploy-aurora` uses `sudo nixos-rebuild switch --flake .#aurora`.
- `just home-switch-macbook` provides user-layer apply path.

### CI/CD path already present
- `Nix Checks` gates lint/eval/dry-build/secret scan.
- `Nix Cache Build` builds Linux + macOS targets and pushes to Cachix.
- `Deploy Aurora` supports `workflow_dispatch` with explicit `ref` and `agent_name`, and also auto-runs on successful cache workflow completion.

### Confirmed bootstrap gap
- `src/systems/x86_64-linux/aurora/hardware/default.nix` still documents placeholder root FS guidance (`/dev/sda1` comment to replace with UUID), indicating DEPL-02 is not yet complete as a repo-defined deterministic bootstrap contract.

### Phase artifact alignment
- 06-01/06-02/06-03 plan drafts already exist and align with requirements; refreshed research should be treated as planning-quality criteria to refine those drafts, not as a net-new phase decomposition.

## Planning-Critical Decisions (Must Be Locked Before Execution)

1. **Bootstrap tool decision (DEPL-02)**
- Recommended default: `nixos-anywhere`-based lane.
- Why: purpose-built for remote unattended NixOS provisioning and aligns with repository-defined reproducibility.
- Lock needed in plan: exact invocation wrapper contract, target host prerequisites, disk assumptions, and secret/auth expectations.

2. **Aurora rollback contract depth (DEPL-01)**
- Required rollback modes:
  - Immediate host rollback: `sudo nixos-rebuild switch --rollback`.
  - Deterministic ref rollback: dispatch `deploy-aurora.yml` with prior known-good `ref`.
- Lock needed in plan: when to use each mode, mandatory post-action verification checks, and where evidence is recorded.

3. **Macbook recovery command contract (DEPL-03)**
- Existing update commands are clear, but recovery precedence is not yet authoritative.
- Lock needed in plan: preferred first-line recovery path (prior-good revision re-apply vs generation rollback command), plus verification checklist.

4. **Evidence standard for requirement closure**
- Lock needed in plan: minimum transcript content for each requirement and whether dry-run proof is acceptable where live reprovision is risky.

## Standard Stack

### Core
| Component | Current State | Purpose | Why It Stays Standard |
|-----------|---------------|---------|------------------------|
| `Justfile` | Present and used across lifecycle operations | Human-facing operational entrypoints | Prevents command drift and keeps lifecycle actions discoverable. |
| `nixos-rebuild` (`.#aurora`) | Present | VPS system switch and generation rollback | Native NixOS lifecycle primitive; required for DEPL-01 rollback path. |
| `nix-darwin` switch (`.#macbook`) | Present | Workstation machine-level updates | Native darwin apply path already wired by repo wrappers. |
| GitHub Actions deploy chain | Present | Repeatable ref-pinned build + remote activation | Centralized, auditable remote deploy behavior; avoids ad hoc SSH runbooks. |
| Cachix Deploy | Present | Pull-based agent activation from cached store paths | Consistent with existing workflow and deterministic store-path activation. |

### Supporting
| Component | Purpose | Planning Use |
|-----------|---------|--------------|
| `just pre-apply-check` | Mandatory local safety gate | Keep as hard precondition for any apply/deploy/rollback procedure docs. |
| `docs/validation-gates.md` | Required CI merge-gate policy | Treat as invariant; do not weaken merge safety while adding lifecycle docs. |
| `docs/secrets-workflow.md` | Runtime-only decryption contract | Ensure bootstrap/deploy/apply runbooks preserve `secrets-auth-preflight` assumptions. |
| `src/systems/x86_64-linux/aurora/hardware/default.nix` | Hardware/filesystem contract | Must be finalized for deterministic reprovision acceptance. |

### Alternatives Considered
| Instead Of | Alternative | Planning Tradeoff |
|------------|------------|-------------------|
| One canonical deploy lane | Parallel deploy frameworks (e.g., custom SSH scripts + existing CI lane) | Violates out-of-scope and increases operational ambiguity. |
| Repo-defined bootstrap automation | Manual reinstall checklist | Fails DEPL-02 repeatability and raises drift risk. |
| Ref-pinned rollback procedure | "Use latest main" emergency retries | Not deterministic; poor auditability under incident pressure. |

## Architecture Patterns

### Pattern 1: Three-Lane Lifecycle Matrix
**What:** Separate bootstrap, update, and rollback contracts with host-specific commands and fixed verification.
**When:** All Phase 6 planning and implementation tasks.

| Host | Bootstrap/Reprovision | Update | Rollback/Recovery | Required Verification |
|------|------------------------|--------|-------------------|-----------------------|
| `aurora` | New wrapper lane (recommended `nixos-anywhere`) | `just secrets-deploy-aurora` or `deploy-aurora.yml` dispatch | `nixos-rebuild switch --rollback` and/or prior ref dispatch | generation list, service health, remote reachability |
| `macbook` | Provisioning prerequisites documented (Nix + secrets auth) | `just home-switch-macbook` (user) / `just secrets-apply-macbook` (machine) | prior-known-good revision/generation path (must be explicitly locked) | build/switch success + key workflow smoke checks |

### Pattern 2: Ref-Pinned Aurora Operations
**What:** Use `workflow_dispatch.ref` in `deploy-aurora.yml` for deterministic forward/rollback deploy targeting.
**When:** Any CI-mediated Aurora deploy action.
**Why:** Deterministic, auditable, and already implemented.

### Pattern 3: Gate-First Local Operations
**What:** `just pre-apply-check` as mandatory first step before apply/deploy/rollback command execution.
**When:** All manual lifecycle procedures.
**Why:** Keeps safety/consistency tied to existing validated repo policy.

### Anti-Patterns to Avoid
- Declaring DEPL-02 done with docs but no runnable bootstrap wrapper.
- Adding a second canonical deploy method that bypasses existing CI/Cachix lane.
- Defining rollback as "boot older generation" without exact operator commands and checks.
- Skipping prerequisite cleanup of known baseline blockers when collecting acceptance evidence.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Remote deploy orchestration | Custom SSH orchestration scripts | Existing GitHub Actions + Cachix deploy path | Already integrated, auditable, and deterministic. |
| Rollback state tracking | Manual notes of "last known good" | Git refs + NixOS generations | Built-in provenance and reproducibility. |
| VPS initial provisioning | Multi-step shell notebook | Single bootstrap wrapper around canonical tool (`nixos-anywhere`) | Required to satisfy DEPL-02 repeatability. |
| Workstation update selection | Ad hoc direct commands | `just` decision tree wrappers | Keeps user-vs-system apply path consistent. |

## Common Pitfalls

### Pitfall 1: Placeholder hardware assumptions survive into "complete" bootstrap
**What goes wrong:** Reprovisioned host needs manual filesystem/device edits after install.
**Why it happens:** Root filesystem contract in aurora hardware module not finalized.
**How to avoid:** Require explicit disk/FS contract completion in 06-01 acceptance criteria.
**Warning signs:** Runbook includes "edit this manually after first boot" steps.

### Pitfall 2: Rollback is documented but not rehearsed
**What goes wrong:** Operator cannot recover quickly during incident.
**Why it happens:** No evidence artifact showing rollback command success and verification outputs.
**How to avoid:** Add mandatory rollback rehearsal section to DEPL-01 deliverable.
**Warning signs:** No transcript containing generation inspection and health checks.

### Pitfall 3: Gate bypass in urgency workflows
**What goes wrong:** Broken/unsafe changes applied during recovery pressure.
**Why it happens:** Docs present direct switch/deploy commands without explicit gate precondition.
**How to avoid:** Every runbook begins with `just pre-apply-check` and defines exceptions explicitly (if any).
**Warning signs:** Recovery runbook starts with activation commands directly.

### Pitfall 4: Existing repo blockers invalidate phase evidence
**What goes wrong:** Acceptance criteria fail for unrelated pre-existing issues.
**Why it happens:** Current state still notes pre-existing blockers (`openclaw` option mismatch, formatting drift impacting preflight).
**How to avoid:** Add "entry cleanup" task or explicit prerequisite to resolve baseline blockers before evidence capture.
**Warning signs:** `just pre-apply-check` fails before lifecycle-specific commands run.

## Code and Workflow Examples

### Existing local gate and host apply wrappers
```bash
# Justfile
just pre-apply-check
just secrets-deploy-aurora
just secrets-apply-macbook
just home-switch-macbook
```

### Existing Aurora workflow dispatch contract
```yaml
# .github/workflows/deploy-aurora.yml
on:
  workflow_dispatch:
    inputs:
      ref:
        description: Git ref to deploy (branch, tag, or SHA)
        required: true
        default: main
```

### Existing Aurora local rollback primitive (NixOS)
```bash
sudo nixos-rebuild switch --rollback
```

## Plan-Ready Tasking Guidance

### Recommended execution order
1. `06-01` (bootstrap/reprovision contract, DEPL-02)
2. `06-02` (deploy/rollback hardening, DEPL-01)
3. `06-03` (workstation apply/recovery contract, DEPL-03)

Reason: both deploy rollback and workstation recovery patterns benefit from a finalized bootstrap/hardware contract and shared evidence standards set in 06-01.

### Definition-of-done checklist by requirement
- **DEPL-02:**
  - One runnable bootstrap wrapper exists in `Justfile`.
  - Aurora hardware contract is explicit and no longer placeholder-driven.
  - `docs/aurora-bootstrap.md` and evidence artifact capture command + verification outputs.
- **DEPL-01:**
  - `docs/aurora-deploy-rollback.md` includes forward + two rollback modes.
  - `deploy-aurora.yml` exposes enough metadata to audit chosen ref/path/agent.
  - Verification checklist includes generation/state/service/reachability checks.
- **DEPL-03:**
  - `docs/macbook-apply-recovery.md` defines decision tree and recovery commands.
  - README links to this runbook as authoritative source.
  - Repeatability claim backed by runbook-level verification outputs.

## Open Questions

1. Which `nixos-anywhere` invocation contract should be canonical for Hetzner?
- What we know: tool is purpose-built for unattended remote NixOS installs.
- Unknown: exact flags/input structure to match this repo's host module + disk assumptions.
- Planning recommendation: lock this in 06-01 Task 2 with a dry-run-able wrapper and explicit prerequisites.

2. What is the primary macbook rollback command to document first?
- What we know: update commands are defined; recovery contract is not fully standardized in current docs.
- Unknown: preferred first-line operator action for regressions.
- Planning recommendation: pick one default path and document alternatives as fallback only.

3. What minimum verification evidence is mandatory vs optional for each lifecycle lane?
- What we know: requirement satisfaction depends on repeatability claims.
- Unknown: whether dry-run proof is sufficient for all artifacts.
- Planning recommendation: set mandatory evidence fields in each 06-0X plan before execution.

## Validation Architecture

`workflow.nyquist_validation` is not enabled in `.planning/config.json`; no Nyquist-specific test architecture section is required.

Practical validation commands for this phase:
- `just pre-apply-check`
- `nix eval .#nixosConfigurations.aurora.config.fileSystems."/".device --raw`
- `just --list | rg 'aurora-bootstrap|aurora-bootstrap-verify'`
- `actionlint .github/workflows/deploy-aurora.yml || yamllint .github/workflows/deploy-aurora.yml`

## Sources

### Primary (HIGH confidence)
- Repository files (current workspace state):
  - `Justfile`
  - `README.md`
  - `.github/workflows/nix-checks.yml`
  - `.github/workflows/nix-cache.yml`
  - `.github/workflows/deploy-aurora.yml`
  - `docs/validation-gates.md`
  - `docs/secrets-workflow.md`
  - `src/systems/x86_64-linux/aurora/default.nix`
  - `src/systems/x86_64-linux/aurora/hardware/default.nix`
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  - `.planning/ROADMAP.md`
  - `.planning/config.json`
  - `.planning/phases/06-repeatable-deployment-lifecycle/06-01-PLAN.md`
  - `.planning/phases/06-repeatable-deployment-lifecycle/06-02-PLAN.md`
  - `.planning/phases/06-repeatable-deployment-lifecycle/06-03-PLAN.md`

### Secondary (MEDIUM confidence, official docs)
- NixOS manual (stable) showing `nixos-rebuild` operations and rollback command:
  - https://nixos.org/manual/nixos/stable/index.html
- Cachix Deploy docs (deploy model, agent activation, deploy spec):
  - https://docs.cachix.org/deploy/index.html
  - https://docs.cachix.org/deploy/deploying-to-agents/
  - https://docs.cachix.org/deploy/reference
- `nixos-anywhere` official repository/documentation entry point:
  - https://github.com/nix-community/nixos-anywhere
- `nix-darwin` official repository/usage docs:
  - https://github.com/nix-darwin/nix-darwin

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH (directly evidenced in repository and active workflows)
- Architecture patterns: HIGH (repo already enforces most boundaries; only bootstrap lane needs concretization)
- Pitfalls: HIGH (derived from current known blockers + explicit requirement gaps)
- External tooling specifics (`nixos-anywhere` invocation details): MEDIUM (needs finalization during 06-01 implementation)

**Research date:** 2026-02-26
**Valid until:** 2026-03-28 or until deployment/bootstrap workflow files materially change.
