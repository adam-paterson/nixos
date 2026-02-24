---
phase: 02-modular-repository-architecture
plan: 01
subsystem: infra
tags: [nix, nix-darwin, modular-architecture, host-composition]
requires:
  - phase: 01-flake-control-plane
    provides: deterministic dual-target flake evaluation/build contract
provides:
  - Darwin workstation collection now defaults macbook override enablement
  - Verified Darwin and host-matrix contracts still evaluate after boundary wiring
affects: [phase-2, darwin, module-boundaries]
tech-stack:
  added: []
  patterns: [thin-host composition, option-gated overrides, collection-first wiring]
key-files:
  created: []
  modified:
    - src/modules/darwin/collections/workstation/default.nix
key-decisions:
  - "Keep macbook override activation defaulted at the workstation collection layer while host remains explicit."
patterns-established:
  - "Darwin host exception modules are wired through collection defaults and explicit host toggles."
requirements-completed: [STRU-01, STRU-02]
duration: 19 min
completed: 2026-02-24
---

# Phase 2 Plan 01: Darwin Thin-Host Boundary Summary

**Darwin workstation composition now defaults into the macbook override boundary and passes contract verification across local eval/build checks.**

## Performance

- **Duration:** 19 min
- **Started:** 2026-02-24T17:28:47Z
- **Completed:** 2026-02-24T17:47:12Z
- **Tasks:** 3
- **Files modified:** 1

## Accomplishments
- Wired `cosmos.overrides.darwin.macbook.enable` into `cosmos.collections.darwin.workstation` defaults.
- Verified `nix build .#darwinConfigurations.macbook.system` succeeds after collection boundary wiring.
- Verified host-matrix contract checks via `just eval` and `nix develop .#ci -c flake-contract`.

## Task Commits

1. **Task 1: Create a dedicated Darwin override module for macbook-only policy** - `9ab8027` (pre-existing in branch state)
2. **Task 2: Wire workstation collection and host composition to keep host file thin** - `e14878b` (feat)
3. **Task 3: Prove Darwin boundary contract with host-matrix checks** - verification-only task (no code delta)

## Files Created/Modified
- `src/modules/darwin/collections/workstation/default.nix` - Adds default wiring for `cosmos.overrides.darwin.macbook.enable` under workstation collection.

## Decisions Made
- Keep override enablement defaulted at collection-level, while preserving explicit host override toggles for discoverability.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Pre-commit hook blocked task commit until scoped bypass was allowed**
- **Found during:** Task 2
- **Issue:** `flake-eval` pre-commit hook repeatedly failed with "files were modified by this hook" while unrelated dirty state existed.
- **Fix:** Isolated staging to task-only file and committed with minimal bypass (`SKIP=flake-eval`) after explicit user approval.
- **Verification:** `alejandra`, `deadnix`, and `statix` hooks still passed; task verification commands were already green.
- **Committed in:** `e14878b`

---

**Total deviations:** 1 auto-fixed issue (Rule 3).
**Impact on plan:** No scope creep; bypass was constrained to the single blocked hook for the single blocked commit.

## Issues Encountered
- Pre-commit hook behavior in dirty worktree required a one-time scoped bypass to complete atomic commit protocol.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Technically ready for next phase work on module boundaries.
- Plan is complete and ready to continue with 02-02.

---
*Phase: 02-modular-repository-architecture*
*Completed: 2026-02-24*

## Self-Check: PASSED

- Found summary file on disk and required `02-01` task commit in git history (`e14878b`).
