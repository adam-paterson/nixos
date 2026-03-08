# Phase 5: Validation and Change Gates - Research

**Researched:** 2026-02-26
**Domain:** Nix pre-apply validation, GitHub merge gates, and controlled flake input change management
**Confidence:** HIGH

<user_constraints>
## User Constraints

No `*-CONTEXT.md` exists for this phase. Use roadmap and requirements as constraints.

### Locked Decisions
- Keep `nix flake check` as the canonical pre-apply integrity gate.
- Use CI checks to block unsafe changes from merging.
- Treat `flake.lock` updates as explicit, reviewable maintenance changes rather than incidental side effects.

### Claude's Discretion
- Define the exact command contract for local and CI gates.
- Define the build-depth required for merge safety.
- Define practical lockfile update governance and evidence requirements.

### Deferred Ideas (OUT OF SCOPE)
- Deployment orchestration and rollback mechanics (Phase 6).
- Additional cross-platform integration test harnesses beyond phase success criteria.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VALD-01 | User can run `nix flake check` to validate repository integrity before apply/deploy | Keep `check.exec` (`nix flake check "path:$PWD" --show-trace`) as mandatory local and CI gate, and pair with explicit host eval/dry-build checks for stronger assurance. |
| VALD-02 | User can run CI checks (format/lint/check/build) that block unsafe changes from merging | Keep `.github/workflows/nix-checks.yml` as the single required merge gate and ensure branch protection/ruleset enforces that status; include explicit build coverage, not only lint/eval. |
| VALD-03 | User can update flake inputs through a controlled workflow with reviewable lockfile diffs | Use documented verify/update lock workflow (`lock-verify`, scoped `lock-update`, diff review checklist) plus CI validation of lock changes before merge. |
</phase_requirements>

## Summary

Phase 5 is mostly a **contract-hardening phase**, not a greenfield implementation. The repository already has key primitives: `just` wrappers, CI workflow coverage (`fmt-check`, `lint`, `check`, `eval`, `secrets-scan`), and explicit lockfile workflow documentation (`docs/flake-lock-workflow.md`). The plan should convert these from "available tooling" into an enforced gate architecture with clear pass/fail ownership.

The most important current-state finding is that `nix flake check` is present and useful, but the flake `checks` attrsets currently evaluate to empty arrays (`nix eval --json .#checks.x86_64-linux --apply builtins.attrNames` returns `[]`). That means merge safety currently relies on script-level checks (`fmt/lint/eval/secrets`) rather than `checks.<system>.*` derivations. This is valid, but should be documented as an intentional design decision and backed by explicit build coverage in CI to satisfy VALD-02.

`VALD-03` is already largely scaffolded: `just lock-verify`, `just lock-sync`, `just lock-update <input>`, and lock diff policy docs exist. Planning should focus on operational guardrails: scoped updates, required `flake.lock` review, and consistent evidence of post-update validation.

**Primary recommendation:** Preserve existing command surfaces, then formalize one mandatory gate contract: local pre-apply (`just ci` + `just lock-verify`) and protected-branch CI merge gate (`Nix Checks` required status) with explicit lockfile-change policy.

## Project Skill Considerations

Repository-local skill inventory under `.agents/skills/` currently contains `using-git-worktrees`.

- Relevance to this phase: indirect but useful during implementation execution (parallel gate/refactor work in isolated branches/worktrees).
- Relevance to research/planning output: no additional technical gate primitives; no changes to recommended validation stack.

## Standard Stack

### Core
| Component | Current State | Purpose | Why Standard Here |
|-----------|---------------|---------|-------------------|
| `nix flake check` | Implemented via `check.exec` in `src/shells/common/default.nix` | Flake integrity/evaluation gate | Canonical Nix gate; already integrated in local + CI paths. |
| `devenv` CI shell + shared scripts | Implemented (`src/shells/ci/default.nix`, `src/shells/common/default.nix`) | Stable, reproducible command surface (`fmt/lint/check/eval/secrets`) | Minimizes drift between local and GitHub Actions execution. |
| GitHub Actions `nix-checks.yml` | Implemented (`.github/workflows/nix-checks.yml`) | Merge-time safety enforcement surface | Existing workflow already centralizes checks and can be the required status gate. |
| `Justfile` lock commands | Implemented (`lock-verify`, `lock-sync`, `lock-update`) | Controlled lock lifecycle and operator ergonomics | Gives deterministic and reviewable `flake.lock` maintenance path. |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `flake-contract` script | Explicit host eval + dry-build matrix checks | Use to strengthen "build" coverage expectations for VALD-02. |
| README lock/CI sections | Operator and reviewer policy surface | Use as canonical policy doc linked from PR templates/reviews. |
| GitHub branch protection/rulesets | Enforce required check pass before merge | Required for VALD-02 to be truly "blocking", not advisory. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Script-defined checks (`fmt/lint/check/eval`) | Full custom `checks.<system>` derivation graph | Pure checks graph is elegant but higher refactor cost now; scripts already working and auditable. |
| One all-in CI workflow status | Multiple independent required statuses | Granular visibility is useful, but too many required checks increases maintenance and ambiguous protection config risk. |
| Manual lock update discipline | Automated broad periodic `nix flake update` | Automation can create noisy lock churn and weaken intent clarity without strict policy filters. |

## Architecture Patterns

### Recommended Project Structure (for this phase)
```text
Justfile                                 # Operator commands and lock/update surfaces
src/shells/common/default.nix            # Ground-truth implementations for check/eval/lint/fmt/scan
src/shells/ci/default.nix                # CI shell package contract
.github/workflows/nix-checks.yml         # Required merge gate workflow
docs/flake-lock-workflow.md              # Lock update policy and review checklist
README.md                                # Human-facing command and gate documentation
```

### Pattern 1: Two-Layer Pre-Apply Gate
**What:** Require both flake integrity (`check`) and host-eval/build confidence (`eval` and/or `flake-contract`) before apply/deploy.
**When to use:** Before any `nix-darwin switch`, `nixos-rebuild switch`, or release/deploy branch merge.
**Why:** `nix flake check` is necessary but can miss intent-specific build assertions if `checks.<system>` is sparse.
**Concrete commands:**
```bash
just check
just eval
nix develop .#ci -c flake-contract
```

### Pattern 2: CI as Merge Gate, Not Just Signal
**What:** Treat `Nix Checks` workflow status as merge-blocking via branch protection/ruleset required checks.
**When to use:** Always on `main`-targeted pull requests.
**Why:** VALD-02 requires blocking unsafe changes from merging, which depends on repository policy, not workflow YAML alone.
**Concrete verification commands:**
```bash
gh run list --workflow "Nix Checks" --limit 5
gh api repos/adam-paterson/nixos/branches/main/protection/required_status_checks
```

### Pattern 3: Intentional Lockfile Change Workflow
**What:** Separate verify path and update path for flake inputs.
**When to use:** Every dependency maintenance change.
**Why:** Prevents accidental graph churn and keeps PR review focused.
**Concrete commands:**
```bash
just lock-verify
just lock-update nixpkgs
git diff -- flake.lock
nix develop .#ci -c ci
```

### Anti-Patterns to Avoid
- Treating passing CI workflow runs as merge blocking without confirming branch protection/ruleset enforcement.
- Using broad `nix flake update` for unrelated feature work.
- Assuming `nix flake check` alone provides sufficient build gate coverage when `checks` attrsets are empty.
- Accepting lockfile PRs without explicit scoped-intent notes and diff review.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pre-apply validation orchestration | New bespoke bash runner for every gate | Existing `just` + `src/shells/common/default.nix` scripts | Already centralized, deterministic, and reused in CI. |
| Merge enforcement | Custom webhook/PR bot gate | Native GitHub branch protection/rulesets + required checks | Native enforcement is auditable and less brittle. |
| Lockfile policy docs | Ad hoc PR comments per update | `docs/flake-lock-workflow.md` + README lock commands | Creates stable, repeatable review criteria. |

**Key insight:** Most risk here is governance drift, not missing tooling. The plan should enforce and verify existing gates rather than replace them.

## Common Pitfalls

### Pitfall 1: `flake check` Overconfidence
**What goes wrong:** Team assumes `nix flake check` means full build safety.
**Why it happens:** `flake check` validates/evaluates outputs and builds `checks` derivations, but current `checks.*` sets are empty in this repo.
**How to avoid:** Keep `flake check` mandatory, but add explicit host dry-build contract (`flake-contract`) in CI and local pre-apply flows.
**Warning signs:** `nix eval --json .#checks.<system> --apply builtins.attrNames` returns `[]` while merge policy claims full build gating.

### Pitfall 2: Non-Enforced CI
**What goes wrong:** Workflow failures are visible but merges still happen.
**Why it happens:** Branch protection/ruleset required statuses are missing or misconfigured.
**How to avoid:** Explicitly verify required status check configuration for `main` and keep job names stable/unique.
**Warning signs:** Failed `Nix Checks` run on PR still allows merge button.

### Pitfall 3: Lockfile Churn Pollution
**What goes wrong:** PRs include unrelated lockfile movement, hiding risky transitive upgrades.
**Why it happens:** Broad update commands or incidental lock rewrites during feature work.
**How to avoid:** Enforce verify path during feature work (`lock-verify`) and scoped updates (`lock-update <input>`).
**Warning signs:** Large multi-input `flake.lock` diff with no explicit dependency-change intent.

### Pitfall 4: Local/CI Contract Drift
**What goes wrong:** Local commands pass, CI fails (or inverse).
**Why it happens:** Different execution surfaces and dependency sets.
**How to avoid:** Always route commands through `nix develop .#ci -c ...` and keep `just` wrappers thin.
**Warning signs:** CI invokes commands not represented by local `just` workflow.

## Code Examples

### Existing flake gate command implementation
```bash
# Source: src/shells/common/default.nix
nix flake check "path:$PWD" --show-trace
```

### Existing CI merge gate sequence
```yaml
# Source: .github/workflows/nix-checks.yml
- run: nix develop .#ci -c fmt-check
- run: nix develop .#ci -c lint
- run: nix develop .#ci -c check
- run: nix develop .#ci -c eval
- run: nix develop .#ci -c secrets-scan
```

### Existing lock governance command surface
```bash
# Source: Justfile
just lock-verify
just lock-sync
just lock-update nixpkgs
```

## State of the Art (Repo-Specific)

| Prior expectation | Current observed state | Phase 5 impact |
|-------------------|------------------------|----------------|
| Need CI quality gate foundations | `nix-checks.yml` and local `ci.exec` already exist | Plan should enforce and close remaining governance gaps rather than rebuild CI from scratch. |
| Need lock update workflow | Explicit lock workflow doc + commands already present | VALD-03 implementation is mainly policy hardening and verification evidence. |
| `flake check` as integrity gate | Implemented and wired in local + CI | Meets VALD-01 baseline; augment with explicit build gate clarity for VALD-02. |

## Open Questions

1. What exact "build" depth is mandatory for merge blocking?
   - What we know: current gate runs `check` + `eval`; host artifact build exists elsewhere (`flake-contract`, cache workflows).
   - What is unclear: whether Phase 5 should require dry-builds in `nix-checks.yml` for both hosts.
   - Recommendation: include at least dry-build of `darwinConfigurations.macbook.system` and `nixosConfigurations.aurora.config.system.build.toplevel` in required gate path.

2. Which GitHub protection model is canonical here: classic branch protection rule or ruleset?
   - What we know: both are supported by GitHub and can enforce required checks.
   - What is unclear: current repository setting state is not visible in-repo.
   - Recommendation: pick one model, document it in README, and add a verification command (`gh api`) to the phase acceptance evidence.

3. Should lock update automation be introduced now?
   - What we know: manual scoped updates already match deterministic workflow goals.
   - What is unclear: appetite for scheduled update automation and review load.
   - Recommendation: keep manual scoped updates in v1; defer automation until post-Phase 6 operational baseline.

## Validation Architecture

This repository's `.planning/config.json` does not define `workflow.nyquist_validation: true`, so no Nyquist-specific validation section is required for this phase research.

## Recommended Plan Slices

1. **Slice A: Harden local pre-apply gate contract (VALD-01)**
- Define canonical local gate command order (`fmt/lint/check/eval` + optional `flake-contract`).
- Ensure README and operator docs map to this single contract.
- Acceptance: reproducible command transcript proving gate behavior on current tree.

2. **Slice B: Enforce CI merge blocking (VALD-02)**
- Ensure `Nix Checks` is the required status on `main` protection/ruleset.
- Add explicit build-depth step if required by acceptance bar.
- Acceptance: failed gate demonstrably blocks merge; passing gate allows merge.

3. **Slice C: Lockfile change governance (VALD-03)**
- Normalize lock verify/update process in docs and PR review checklist language.
- Require scoped update intent + `flake.lock` diff review evidence.
- Acceptance: sample input update PR path with scoped diff and full gate pass.

## Sources

### Primary (HIGH confidence)
- Repository evidence:
  - `Justfile`
  - `src/shells/common/default.nix`
  - `src/shells/ci/default.nix`
  - `.github/workflows/nix-checks.yml`
  - `docs/flake-lock-workflow.md`
  - `README.md`
- Command evidence executed in this workspace:
  - `nix eval --json .#checks.x86_64-linux --apply builtins.attrNames` (returned `[]`)
  - `nix eval --json .#darwinConfigurations --apply builtins.attrNames` (returned `["macbook"]`)
  - `nix eval --json .#nixosConfigurations --apply builtins.attrNames` (returned `["aurora"]`)

### Secondary (MEDIUM confidence)
- Nix reference manual:
  - `https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake-check`
  - `https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake-lock`
- GitHub docs:
  - `https://docs.github.com/github/administering-a-repository/about-branch-restrictions`
  - `https://docs.github.com/en/rest/branches/branch-protection`

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all core components are present and directly inspectable in-repo.
- Architecture: HIGH - local and CI command flows are concrete and executable.
- Pitfalls: MEDIUM-HIGH - one key risk (branch protection state) is operational and not stored in repository files.

**Research date:** 2026-02-26
**Valid until:** 2026-03-28 (or until CI/protection/lock workflow changes)
