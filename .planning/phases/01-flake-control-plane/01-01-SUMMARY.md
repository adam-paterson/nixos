---
phase: 01-flake-control-plane
plan: 01
subsystem: infra
tags: [nix, flakes, devenv, pre-commit, darwin, nixos]
requires:
  - phase: 01-flake-control-plane
    provides: Existing dual-target flake outputs for Darwin and NixOS hosts
provides:
  - Host-matrix flake evaluation by dynamic attr discovery
  - Single flake contract command for eval plus dry-build across all hosts
  - Pre-commit hook alignment with the same contract behavior
affects: [phase-01-plan-02, validation-gates, deployment-workflows]
tech-stack:
  added: []
  patterns:
    - Attr-name discovery loops for host matrices via `nix eval --apply builtins.attrNames`
    - Shared contract command reuse from both CI shell and pre-commit hook
key-files:
  created:
    - .planning/phases/01-flake-control-plane/01-01-SUMMARY.md
  modified:
    - src/shells/common/default.nix
    - src/shells/dev/default.nix
key-decisions:
  - "Use `flake-contract` as the single host-matrix contract entrypoint for eval and dry-build checks."
  - "Run hook validation through `nix develop path:$PWD#ci -c flake-contract` so pre-commit uses identical contract logic."
patterns-established:
  - "Contract First: One script validates both Darwin and NixOS host outputs from flake attrs."
  - "Hook Parity: Local pre-commit checks call the same contract command used by CI entrypoints."
requirements-completed: [CORE-01, CORE-03]
duration: 12 min
completed: 2026-02-24
---

# Phase 1 Plan 1: Host Matrix Contract Summary

**Dynamic host discovery now drives deterministic eval and dry-build validation for every declared Darwin and NixOS flake target from one contract command.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-02-24T14:42:42Z
- **Completed:** 2026-02-24T14:55:15Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments
- Replaced hardcoded host checks with attr discovery loops in `eval.exec`.
- Added `flake-contract.exec` to evaluate and dry-build each discovered Darwin and NixOS system target.
- Updated `flake-eval` hook to execute the shared contract flow via the CI shell.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace host-hardcoded eval checks with flake attr discovery loops** - `44c19ac` (feat)
2. **Task 2: Add explicit dual-target dry-build contract command** - `b38b06a` (feat)
3. **Task 3: Align pre-commit flake evaluation hook with contract behavior** - `ed37470` (feat)

**Plan metadata:** `TBD` (docs: complete plan)

## Files Created/Modified
- `.planning/phases/01-flake-control-plane/01-01-SUMMARY.md` - Execution summary for plan 01-01
- `src/shells/common/default.nix` - Host discovery eval loop and dual-target dry-build contract command
- `src/shells/dev/default.nix` - Flake-eval hook updated to invoke contract behavior through CI shell

## Decisions Made
- Standardized on `flake-contract` as the single contract entrypoint to keep host-matrix checks deterministic and reusable.
- Hook invocation uses `nix develop path:$PWD#ci -c flake-contract` because direct `flake-contract` is not available in pre-commit hook runtime PATH.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Pre-commit runner command unavailable in dev shell**
- **Found during:** Task 3 verification
- **Issue:** `pre-commit run flake-eval --all-files` could not run because `pre-commit` command was not present.
- **Fix:** Used the available `prek` runner (`nix develop .#dev -c prek run flake-eval --all-files`) for hook verification.
- **Files modified:** None
- **Verification:** `nix develop .#dev -c prek run flake-eval --all-files` passed
- **Committed in:** N/A (verification path adjustment only)

**2. [Rule 3 - Blocking] Hook script could not resolve `flake-contract` directly**
- **Found during:** Task 3 commit hook execution
- **Issue:** `flake-eval` failed with `flake-contract: command not found` in pre-commit hook runtime.
- **Fix:** Updated hook entry to run `nix develop \"path:$PWD#ci\" -c flake-contract`.
- **Files modified:** src/shells/dev/default.nix
- **Verification:** Commit hook passed and `nix develop .#dev -c prek run flake-eval --all-files` passed
- **Committed in:** `ed37470`

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both fixes were required to complete Task 3 verification and preserve one-command contract parity.

## Issues Encountered
- Pre-commit hooks repeatedly reformatted modified `.nix` files during task commits; resolved by re-staging formatter output before final task commits.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Plan 01-01 contract layer is complete and executable for all declared system targets.
- Ready for `01-02-PLAN.md` lockfile workflow hardening.

---
*Phase: 01-flake-control-plane*
*Completed: 2026-02-24*

## Self-Check: PASSED
- FOUND: .planning/phases/01-flake-control-plane/01-01-SUMMARY.md
- FOUND: task commits (44c19ac, b38b06a, ed37470)
