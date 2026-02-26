# Phase 07: Secrets Gap Closure - Research

**Researched:** 2026-02-26
**Domain:** Nix + Home Manager runtime-secret enforcement and milestone re-verification closure
**Confidence:** HIGH

## Summary

Phase 07 is primarily a **gap-closure and evidence-correction phase**, not a net-new secrets architecture phase. The milestone audit (`.planning/v1.0-v1.0-MILESTONE-AUDIT.md`) and Phase 4 verification (`.planning/phases/04-secrets-safe-configuration/04-VERIFICATION.md`) report two blockers: a plaintext OpenClaw token literal and missing full-repo secret scan signoff. Current repository code state suggests the OpenClaw plaintext issue has already been remediated in working tree, but the verification artifacts were not re-run/updated to reflect that state.

The planning focus should therefore be: (1) normalize implementation so OpenClaw remains runtime-secret-only with no regression path, (2) add an explicit full-repo scan mode and signoff surface in command + CI + docs, and (3) produce authoritative re-verification evidence that closes `SECR-01` and `SECR-02` in milestone tracking.

**Primary recommendation:** Treat Phase 07 as an audit remediation package with three slices: runtime wiring confirmation, full-repo scan contract, and verification artifact reconciliation.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SECR-01 | User can store only encrypted secrets in git and decrypt them at activation/deploy time | Existing SOPS files + HM `sops` declarations and session `_FILE` export pattern are present; plan needs anti-regression checks and updated verification artifacts. |
| SECR-02 | User can apply configurations without exposing plaintext secrets in Nix evaluation paths or store artifacts | OpenClaw now appears to consume `tokenFile` from runtime secret path env; plan needs proof commands and full-repo scan signoff to guarantee no legacy plaintext remains. |
</phase_requirements>

## Standard Stack

### Core
| Component | Current State | Purpose | Why Standard Here |
|-----------|---------------|---------|-------------------|
| `sops-nix` Home Manager module | Enabled in `src/modules/home/security/secrets/default.nix` | Runtime secret materialization and path handoff | Existing established pattern in this repo; no alternate stack needed for closure work. |
| Host-scoped encrypted SOPS file | `secrets/hosts/aurora.yaml` includes `hosts.aurora.openclaw.gateway_auth_token` | OpenClaw gateway token source of truth (encrypted) | Directly supports replacing literals with runtime secret references. |
| Runtime path export via session var | `OPENCLAW_GATEWAY_AUTH_TOKEN_FILE` from `config.sops.secrets.*.path` | Decouples secrets from evaluated Nix values | Satisfies runtime-only design constraint already used elsewhere in repo. |
| `gitleaks`-based `secrets-scan` | `src/shells/common/default.nix` | Detect plaintext leaks in tracked changes | Existing guardrail; needs explicit full-repo mode for milestone signoff. |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `Justfile` wrappers | Canonical operator interface (`secrets-*`) | Make scan/apply/deploy behavior consistent and discoverable. |
| `.github/workflows/nix-checks.yml` | CI enforcement path | Must carry signoff-level secret scan mode in addition to PR diff scanning. |
| `04-VERIFICATION.md` + milestone audit | Requirement closure evidence | Must be updated after remediation to close Phase 07. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Reworking secrets framework | Move to agenix or custom scripts | High churn and out-of-scope; no requirement demands this. |
| Full-repo scan as default on every local run | Keep only diff-based scans | Full-default is noisy/slow for dev loops; better to keep diff-fast path plus explicit full-scope signoff command. |

## Architecture Patterns

### Recommended Project Structure (for this phase)
```text
src/modules/home/security/secrets/default.nix           # secret declarations + session variable exports
src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix
src/shells/common/default.nix                           # scan scope implementation
Justfile                                                # canonical wrappers
.github/workflows/nix-checks.yml                        # CI signoff wiring
docs/secrets-workflow.md                                # operator contract
.planning/phases/04-secrets-safe-configuration/04-VERIFICATION.md
.planning/v1.0-v1.0-MILESTONE-AUDIT.md
```

### Pattern 1: Runtime Secret Path Handoff (OpenClaw)
**What:** Keep OpenClaw gateway auth wired to a runtime secret file path, not a literal.
**When to use:** Always for any credential-bearing OpenClaw auth fields.
**Repo evidence:**
- `src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix` uses `gateway.auth.tokenFile = config.home.sessionVariables.OPENCLAW_GATEWAY_AUTH_TOKEN_FILE`.
- `src/modules/home/security/secrets/default.nix` exports `OPENCLAW_GATEWAY_AUTH_TOKEN_FILE = config.sops.secrets."hosts/aurora/openclaw/gateway_auth_token".path`.

### Pattern 2: Required Secret Assertion Coverage
**What:** Ensure required secret keys are declared and validated via assertions.
**When to use:** For every required host/user secret key in HM secret profile.
**Repo evidence:**
- `requiredSecretNames` includes `hosts/aurora/openclaw/gateway_auth_token` for user `adam`.
- Assertion fails with explicit diagnostics if required declarations are missing.

### Pattern 3: Dual-Mode Secret Scanning
**What:** Maintain fast changed-file scans for dev feedback and add full-repo mode for signoff.
**When to use:**
- `staged`/`diff-base`: daily developer and PR guardrails.
- `full`: phase closure, release, and periodic hygiene gates.
**Gap:** current `secrets-scan` implementation supports `staged`, `diff-base`, and `working-tree`; it does not yet include explicit `full` scope.

### Anti-Patterns to Avoid
- Assuming verification docs match runtime code without re-running proof commands.
- Declaring requirement closure from partial scan scopes only.
- Reintroducing token literals or fallback defaults in any `.nix` consumer.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Secret runtime wiring | Custom env/file export scripts outside modules | Existing `sops-nix` + HM module declarations | Already integrated, typed, and host-aware in repo. |
| Secret scanning | New regex scanner | Existing `gitleaks` wrapper in `src/shells/common/default.nix` | Existing policy/allowlist and CI integration already present. |
| Requirement evidence | Informal notes in PR/comments | `*-VERIFICATION.md` + milestone audit re-verification updates | Required by project planning/audit flow; machine-readable closure. |

**Key insight:** Phase 07 success depends more on **traceable evidence alignment** than on introducing new primitives.

## Common Pitfalls

### Pitfall 1: Code/Evidence Drift
**What goes wrong:** Code appears fixed, but verification and audit files still report blockers.
**Why it happens:** Implementation lands outside the original phase verification update loop.
**How to avoid:** Make re-verification artifact updates a first-class plan slice with explicit acceptance checks.
**Warning signs:** Audit references line-level issues that no longer exist in source.

### Pitfall 2: Scan Coverage Blind Spot
**What goes wrong:** Diff-only scan misses pre-existing plaintext in untouched files.
**Why it happens:** Guardrails optimized for incremental changes only.
**How to avoid:** Add and document a mandatory full-repo scan signoff path.
**Warning signs:** `secrets-scan` has no `full` mode; docs mention only changed-file scans.

### Pitfall 3: Requirement Closure Without Requirement Mapping
**What goes wrong:** Work is done but `SECR-01`/`SECR-02` remain unchecked in milestone traceability.
**Why it happens:** Technical fixes are not mapped back into planning artifacts.
**How to avoid:** Re-verification table must explicitly cite both requirements as satisfied with evidence lines.
**Warning signs:** `REQUIREMENTS.md` still pending despite code-level changes.

## Code Examples

### Runtime OpenClaw secret consumption pattern
```nix
# src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix
gateway.auth = {
  mode = "token";
  tokenFile = config.home.sessionVariables.OPENCLAW_GATEWAY_AUTH_TOKEN_FILE;
};
```

### HM secret export pattern for OpenClaw
```nix
# src/modules/home/security/secrets/default.nix
home.sessionVariables.OPENCLAW_GATEWAY_AUTH_TOKEN_FILE =
  config.sops.secrets."hosts/aurora/openclaw/gateway_auth_token".path;
```

### Existing secrets-scan scope gate (needs extension)
```bash
# src/shells/common/default.nix (current)
case "$scan_scope" in
  staged|diff-base|working-tree) ... ;;
  *) exit 1 ;;
esac
```

## State of the Art (Repo-Specific)

| Prior state (audit view) | Current observed code state | Impact on Phase 07 |
|--------------------------|-----------------------------|--------------------|
| OpenClaw token literal in tracked Nix | OpenClaw now uses `tokenFile` runtime path handoff | Likely blocker already fixed in implementation; must re-verify and update artifacts. |
| Changed-file scan only | Still true in implementation (`staged`/`diff-base`/`working-tree` only) | Full-repo signoff gap remains and must be implemented. |
| Phase 4 verification `gaps_found` | Still not updated | Phase 07 must close evidence loop to restore milestone security guarantees. |

## Open Questions

1. Was OpenClaw runtime token wiring intentionally completed outside formal Phase 4 closure docs?
- What we know: source files now show runtime path usage.
- What is unclear: whether this is final intended implementation or in-progress local change.
- Recommendation: include anti-regression checks in Phase 07 plan and verify against committed target state.

2. Which CI surfaces should run full-repo scan?
- What we know: workflow currently runs diff-base on PR/push/workflow_dispatch.
- What is unclear: whether full mode should run on `push main`, `workflow_dispatch`, or both.
- Recommendation: at minimum run full mode on `push main` and manual signoff dispatch.

3. How should milestone files be updated for closure?
- What we know: `04-VERIFICATION.md` and milestone audit both still report gaps.
- What is unclear: whether Phase 07 will update Phase 4 verification in-place or produce distinct re-verification artifact.
- Recommendation: do both if needed for traceability: update Phase 4 verification with re-verification section and regenerate milestone audit outcome.

## Validation Architecture

This repository's `.planning/config.json` does not define `workflow.nyquist_validation: true`, so no Nyquist-specific validation section is required for this phase research.

## Recommended Plan Slices

1. **Slice A: Runtime-only OpenClaw hardening and proof**
- Confirm and retain runtime `tokenFile` path wiring.
- Verify required secret declarations and encrypted key presence.
- Add explicit regression check proving no token literal appears in OpenClaw config path.
- Acceptance: `nix eval` + `nix build --dry-run` evidence for `adam@aurora` home config with runtime secret path references.

2. **Slice B: Full-repo secret-scan signoff path**
- Extend `secrets-scan` to support `SECRETS_SCAN_SCOPE=full`.
- Add `just secrets-scan-full` wrapper.
- Wire CI to execute full mode on signoff surfaces while preserving diff-based PR guardrails.
- Acceptance: both diff and full modes pass/fail as expected and are documented.

3. **Slice C: Requirement re-verification and milestone closure evidence**
- Re-run Phase 4/7 truth checks and explicitly map evidence to `SECR-01` and `SECR-02`.
- Update verification/audit artifacts so requirement status is unambiguous.
- Acceptance: milestone audit no longer lists `SECR-01`/`SECR-02` as unsatisfied; broken-flow entry resolved.

## Sources

### Primary (HIGH confidence)
- `.planning/v1.0-v1.0-MILESTONE-AUDIT.md` (gap statements and closure criteria)
- `.planning/phases/04-secrets-safe-configuration/04-VERIFICATION.md` (current blocker evidence and requirement status)
- `src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix` (current OpenClaw auth wiring)
- `src/modules/home/security/secrets/default.nix` (secret declarations + runtime session variable export)
- `secrets/hosts/aurora.yaml` (encrypted OpenClaw secret key presence)
- `src/shells/common/default.nix` (scan scope implementation)
- `Justfile` (operator command surface)
- `.github/workflows/nix-checks.yml` (CI scan invocation)
- `docs/secrets-workflow.md` (workflow contract docs)

### Secondary (MEDIUM confidence)
- `.planning/phases/04-secrets-safe-configuration/04-04-PLAN.md` (pre-existing but not executed closure plan blueprint)

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all components already implemented in-repo and directly inspectable.
- Architecture: HIGH - cross-file linkages are concrete and validated via source reads.
- Pitfalls: HIGH - directly evidenced by mismatch between audit docs and current code state.

**Research date:** 2026-02-26
**Valid until:** 2026-03-28 (or next secrets workflow change)
