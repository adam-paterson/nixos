---
phase: 04-secrets-safe-configuration
plan: 01
subsystem: infra
tags: [sops-nix, sops, age, onepassword, secrets]

# Dependency graph
requires:
  - phase: 03-cross-host-user-environment
    provides: cross-host composition boundaries for system and home modules
provides:
  - pinned sops-nix flake input for cross-target runtime decryption support
  - path-scoped SOPS policy for shared and host-specific encrypted files
  - encrypted secret artifact scaffold plus onboarding-safe dummy template
affects: [04-02, 04-03, secrets, runtime-decryption]

# Tech tracking
tech-stack:
  added: [sops-nix]
  patterns: [encrypted-only git artifacts, shared-plus-host secret partitioning, path-regex recipient policy]

key-files:
  created: [.sops.yaml, secrets/shared/common.yaml, secrets/hosts/aurora.yaml, secrets/hosts/macbook.yaml, secrets/templates/env.example]
  modified: [flake.nix, flake.lock]

key-decisions:
  - "Use one SOPS policy file with explicit path_regex rules for shared and per-host files."
  - "Scaffold encrypted files with dummy marker payloads so git stores ciphertext while onboarding remains explicit."

patterns-established:
  - "Secrets live under secrets/shared and secrets/hosts with deterministic file names."
  - "Templates under secrets/templates must use DUMMY_NOT_A_SECRET markers only."

requirements-completed: [SECR-01]

# Metrics
duration: 0 min
completed: 2026-02-25
---

# Phase 4 Plan 01: Encrypted Secret Artifact Foundation Summary

**Pinned `sops-nix` and established encrypted shared/host SOPS artifacts plus a safe dummy bootstrap template aligned to 1Password-as-source-of-truth workflows.**

## Performance

- **Duration:** 0 min
- **Started:** 2026-02-25T10:19:27Z
- **Completed:** 2026-02-25T10:24:18Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- Added `sops-nix` input to `flake.nix` and locked it in `flake.lock`.
- Created `.sops.yaml` creation rules and encrypted shared/host secret files with SOPS metadata.
- Added onboarding-safe `secrets/templates/env.example` containing only explicit dummy markers.

## Task Commits

Each task was committed atomically:

1. **Task 1: Pin sops-nix for cross-target secret decryption support** - `11d4b8a` (feat)
2. **Task 2: Create SOPS policy and encrypted shared/host secret files** - `9909e08` (feat)
3. **Task 3: Add onboarding-safe placeholder template for developer bootstrap** - `c1e206e` (feat)

**Plan metadata:** recorded in final docs commit for this plan.

## Files Created/Modified
- `flake.nix` - Added `sops-nix` flake input following `nixpkgs`.
- `flake.lock` - Pinned `sops-nix` revision for deterministic dependency graph.
- `.sops.yaml` - Added creation rules for shared and host-scoped secret files.
- `secrets/shared/common.yaml` - Encrypted shared secret scaffold with SOPS metadata.
- `secrets/hosts/aurora.yaml` - Encrypted aurora-only secret scaffold.
- `secrets/hosts/macbook.yaml` - Encrypted macbook-only secret scaffold.
- `secrets/templates/env.example` - Dummy-only onboarding template for runtime value resolution.

## Decisions Made
- Used deterministic `secrets/shared` and `secrets/hosts/<host>.yaml` partitioning to support host-scoped runtime wiring in later plans.
- Kept 1Password alignment by storing only encrypted values in tracked artifacts and documenting dummy placeholders separately.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] SOPS encryption failed when source temp file bypassed creation rules**
- **Found during:** Task 2 (Create SOPS policy and encrypted shared/host secret files)
- **Issue:** Initial encryption attempt used temporary file paths that did not match `.sops.yaml` `path_regex` rules.
- **Fix:** Re-ran encryption with `--filename-override` targeting repository secret paths so creation rules applied correctly.
- **Files modified:** `secrets/shared/common.yaml`, `secrets/hosts/aurora.yaml`, `secrets/hosts/macbook.yaml`
- **Verification:** `sops -d` succeeds for all three encrypted files with available local key material.
- **Committed in:** `9909e08` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Auto-fix was necessary to produce valid encrypted artifacts under the intended path-based policy; no scope creep.

## Issues Encountered
- `sops --encrypt` does not apply `.sops.yaml` rules from temp-file paths without filename override; resolved during Task 2.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Ready for `04-02-PLAN.md` runtime decryption wiring across NixOS, nix-darwin, and Home Manager.
- Secret artifact layout and SOPS policy are now in place for host-scoped module integration.

## Self-Check: PASSED
- Verified summary file exists on disk.
- Verified task commits `11d4b8a`, `9909e08`, and `c1e206e` exist in git history.

---
*Phase: 04-secrets-safe-configuration*
*Completed: 2026-02-25*
