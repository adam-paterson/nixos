---
phase: 03-cross-host-user-environment
plan: 02
subsystem: infra
tags: [nix, home-manager, workflow, documentation]

requires:
  - phase: 03-cross-host-user-environment
    provides: shared home baseline and thin host home composition
provides:
  - Canonical `just` command wrappers for cross-host Home Manager apply/build operations.
  - Activation decision guidance that separates user-layer apply from machine-level rebuilds.
  - Phase verification evidence tying HOME-01 to reproducible repository commands.
affects: [phase-04, operator-workflow, homeConfigurations]

tech-stack:
  added: []
  patterns: [single-command-surface, apply-vs-rebuild-decision-tree, evidence-first-verification]

key-files:
  created:
    - .planning/phases/03-cross-host-user-environment/03-VERIFICATION.md
    - .planning/phases/03-cross-host-user-environment/03-02-SUMMARY.md
  modified:
    - Justfile
    - README.md
    - src/homes/README.md
    - .planning/ROADMAP.md
    - .planning/phases/03-cross-host-user-environment/deferred-items.md

key-decisions:
  - "Expose Home Manager operations through explicit `just home-*` wrappers to keep one discoverable workflow across hosts."
  - "Document a strict apply-vs-rebuild decision tree so user-layer changes do not trigger unnecessary system rebuilds."
  - "Treat local Darwin inability to build uncached Linux derivations as an executor constraint and capture dry-run evidence in phase verification."

patterns-established:
  - "Root README and local directory README must align on canonical operational command surface."
  - "Requirement closure in planning should include an explicit verification report with command-level evidence."

requirements-completed: [HOME-01]

duration: 2 min
completed: 2026-02-24
---

# Phase 3 Plan 02: Cross-Host Home Apply Contract Summary

**Canonical `just` wrappers now provide one cross-host Home Manager apply workflow, with explicit apply-vs-rebuild guidance and recorded HOME-01 verification evidence.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-24T22:06:51Z
- **Completed:** 2026-02-24T22:09:31Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments
- Added explicit Home Manager command wrappers for both targets (`home-switch-*`, `home-build-*`, `home-check`) in repository entrypoints.
- Updated operator docs to provide an unambiguous decision tree for user-layer apply versus full system rebuild commands.
- Created Phase 3 verification evidence and updated roadmap progress to close the final Phase 3 plan.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add canonical cross-host Home Manager command wrappers** - `47015a7` (feat)
2. **Task 2: Document activation decision tree and host expectations** - `5c5abbe` (docs)
3. **Task 3: Record requirement evidence for HOME-01 completion** - `b86097a` (docs)

## Files Created/Modified
- `Justfile` - Added canonical home build/switch/check recipes for macbook and aurora.
- `README.md` - Added user-facing Home Manager command flow and activation decision tree.
- `src/homes/README.md` - Aligned thin-home contract docs to canonical cross-host apply workflow.
- `.planning/phases/03-cross-host-user-environment/03-VERIFICATION.md` - Added requirement-level evidence log for HOME-01.
- `.planning/ROADMAP.md` - Marked `03-02` complete and Phase 3 progress as complete.
- `.planning/phases/03-cross-host-user-environment/deferred-items.md` - Logged repeated local Darwin->Linux build constraint context for traceability.

## Decisions Made
- Use `just` as the single command surface for cross-host Home Manager operations.
- Keep docs explicit about when Home Manager switch is correct versus when system rebuild is required.
- Preserve existing executor constraint handling by recording `--dry-run` validation when full Linux builds are unavailable on Darwin.

## Deviations from Plan

None - plan executed as written for implementation scope.

## Issues Encountered
- `nix build .#homeConfigurations."adam@aurora".activationPackage` cannot fully realize uncached `x86_64-linux` derivations from this `aarch64-darwin` executor; verification report includes direct failure evidence plus `--dry-run` evaluation coverage.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 3 command contract and verification evidence are complete.
- Ready to begin Phase 4 (`04-secrets-safe-configuration`) planning/execution.

---
*Phase: 03-cross-host-user-environment*
*Completed: 2026-02-24*

## Self-Check: PASSED
