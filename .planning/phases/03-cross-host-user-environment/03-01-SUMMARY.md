---
phase: 03-cross-host-user-environment
plan: 01
subsystem: infra
tags: [nix, home-manager, snowfall, darwin, linux]

requires:
  - phase: 02-modular-repository-architecture
    provides: thin host composition boundaries and module placement contracts
provides:
  - Shared Home Manager defaults use `mkDefault` with host-aware fallbacks.
  - MacBook and Aurora homes are reduced to host facts and explicit overrides.
  - Cross-host repository checks are documented with current platform constraints.
affects: [03-02, homeConfigurations, cross-host-user-layer]

tech-stack:
  added: []
  patterns: [shared-default-then-host-override, host-aware-fallbacks, thin-homes]

key-files:
  created:
    - .planning/phases/03-cross-host-user-environment/deferred-items.md
  modified:
    - src/modules/home/collections/base/default.nix
    - src/modules/home/dev/shell/default.nix
    - src/modules/home/dev/git/default.nix
    - src/modules/home/dev/tmux/default.nix
    - src/modules/home/dev/neovim/default.nix
    - src/homes/aarch64-darwin/adampaterson@macbook/default.nix
    - src/homes/x86_64-linux/adam@aurora/default.nix

key-decisions:
  - "Shared shell, git, tmux, and neovim defaults now use mkDefault so host files keep override precedence explicit."
  - "Git signing now has a host-aware fallback (`op-ssh-sign` on Darwin, `ssh-keygen` on Linux-compatible paths)."
  - "Aurora home verification on Darwin uses dry-run plus contract checks when uncached Linux builds are unavailable locally."

patterns-established:
  - "Module baseline defaults should use mkDefault for host override safety."
  - "Host homes should keep only identity facts plus bounded local exceptions."

requirements-completed: [HOME-01]

duration: 6 min
completed: 2026-02-24
---

# Phase 3 Plan 01: Cross-Host User Baseline Summary

**Cross-host Home Manager defaults were normalized into reusable modules with explicit host override precedence and thin per-host home composition.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-24T21:57:35Z
- **Completed:** 2026-02-24T22:03:11Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments
- Centralized shell, git, tmux, and neovim shared behavior with `mkDefault` semantics for safe host overrides.
- Simplified both host homes by removing redundant policy that is now inherited from shared collections/modules.
- Executed repository contract checks (`just eval` and `nix develop .#ci -c flake-contract`) and recorded a local platform build constraint for follow-up.

## Task Commits

Each task was committed atomically:

1. **Task 1: Harden shared Home collections as the canonical cross-host baseline** - `0088a21` (feat)
2. **Task 2: Thin both host homes to facts plus explicit local overrides** - `45cff26` (refactor)
3. **Task 3: Prove cross-host consistency through repository contract checks** - `a6f7855` (chore)

## Files Created/Modified
- `.planning/phases/03-cross-host-user-environment/deferred-items.md` - Deferred note for local Darwin-to-Linux build constraint.
- `src/modules/home/collections/base/default.nix` - Shared secret reference placeholders now defaultable for host override precedence.
- `src/modules/home/dev/shell/default.nix` - Added host-aware default TERM and defaultable editor variables.
- `src/modules/home/dev/git/default.nix` - Made workflow defaults override-safe and added host-aware SSH signing fallback.
- `src/modules/home/dev/tmux/default.nix` - Converted tmux behavior defaults to `mkDefault`.
- `src/modules/home/dev/neovim/default.nix` - Converted editor/session defaults to `mkDefault`.
- `src/homes/aarch64-darwin/adampaterson@macbook/default.nix` - Removed redundant host-local override now provided by shared defaults.
- `src/homes/x86_64-linux/adam@aurora/default.nix` - Removed duplicated shared policy and retained explicit host-only OpenClaw exception.

## Decisions Made
- Shared module defaults should be override-friendly by default (`mkDefault`) to preserve host-local precedence.
- Host homes should not duplicate shared policy when a reusable module already provides it.
- On this Darwin executor, Linux activation package verification falls back to dry-run plus matrix contract checks when full Linux builds require uncached artifacts.

## Deviations from Plan

None - plan executed as written for implementation scope. Verification used one constrained fallback due local platform limits, documented in deferred items.

## Issues Encountered
- Full `nix build .#homeConfigurations."adam@aurora".activationPackage` could not complete on local `aarch64-darwin` because uncached `x86_64-linux` derivations require a Linux builder. Logged in `.planning/phases/03-cross-host-user-environment/deferred-items.md`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Shared cross-host user baseline is normalized and host homes are thin.
- Ready for `03-02` command-contract work and cross-host apply workflow documentation.

---
*Phase: 03-cross-host-user-environment*
*Completed: 2026-02-24*

## Self-Check: PASSED
