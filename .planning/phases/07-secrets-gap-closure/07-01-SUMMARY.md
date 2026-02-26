---
phase: 07-secrets-gap-closure
plan: 01
subsystem: infra
tags: [secrets, openclaw, home-manager, sops]
requires:
  - phase: 04-secrets-safe-configuration
    provides: runtime secrets module baseline and encrypted host secret artifacts
provides:
  - OpenClaw gateway auth enforces runtime-only token file consumption via Home Manager secret path exports
  - Home Manager secrets module requires and exports OpenClaw gateway token path for `adam@aurora`
  - Raw anti-regression evidence proving absence of plaintext token literals in tracked OpenClaw config
affects: [phase-07-verification, secrets-runtime-contract]
tech-stack:
  added: []
  patterns: [runtime-only tokenFile handoff, required secret assertion guardrails]
key-files:
  created: [.planning/phases/07-secrets-gap-closure/07-01-EVIDENCE.md, .planning/phases/07-secrets-gap-closure/07-01-SUMMARY.md]
  modified: [src/modules/home/security/secrets/default.nix, src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix]
key-decisions:
  - "OpenClaw gateway auth must consume `OPENCLAW_GATEWAY_AUTH_TOKEN_FILE` through `tokenFile`; inline token literals are forbidden."
  - "Home Manager secrets profile for `adam` must include `hosts/aurora/openclaw/gateway_auth_token` as a required secret."
patterns-established:
  - "OpenClaw auth wiring follows runtime path export from `config.sops.secrets` to program config without plaintext fallbacks."
requirements-completed: [SECR-01, SECR-02]
duration: 5 min
completed: 2026-02-26
---

# Phase 7 Plan 01: OpenClaw Runtime-Only Secret Wiring Summary

**Hardened OpenClaw gateway token handling to runtime-only secret path consumption and captured anti-regression evidence proving plaintext token literals are absent from tracked configuration.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-26T20:45:00Z
- **Completed:** 2026-02-26T20:50:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Added explicit runtime-only token path assertion in OpenClaw aurora config and removed plaintext fallback path risk.
- Ensured Home Manager secrets profile declares and exports `hosts/aurora/openclaw/gateway_auth_token` as a required runtime secret.
- Captured raw command outputs and grep checks in `07-01-EVIDENCE.md` for downstream authoritative verification.

## Task Commits

Each task was committed atomically:

1. **Task 1: Enforce runtime-only OpenClaw token wiring and remove literal fallback paths** - `40f7f89` (fix)
2. **Task 2: Add anti-regression checks for plaintext token reintroduction** - `6b2f5f7` (docs)

## Files Created/Modified
- `.planning/phases/07-secrets-gap-closure/07-01-EVIDENCE.md` - Raw command evidence and anti-regression grep output.
- `.planning/phases/07-secrets-gap-closure/07-01-SUMMARY.md` - Plan execution summary.
- `src/modules/home/security/secrets/default.nix` - Required secret declarations/assertions and runtime env export for OpenClaw token path.
- `src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix` - Runtime-only `tokenFile` consumption with non-empty token path assertion.

## Decisions Made
- Retained runtime-only `tokenFile` pattern as the sole OpenClaw auth contract.
- Kept authoritative requirement closure updates deferred to Plan `07-03`; this plan only captures implementation and raw evidence.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Environment] Nix daemon/cache constraints prevented local execution of eval/dry-run commands in this sandbox**
- **Found during:** Task 1 and Task 2 verification commands
- **Issue:** `nix eval` and `nix build --dry-run` encountered sandboxed fetcher cache / daemon access errors.
- **Fix:** Captured the exact command outputs and completed static anti-regression verification through targeted `rg` checks; deferred authoritative closure to Plan 07-03 where verification reconciliation occurs.
- **Files modified:** `.planning/phases/07-secrets-gap-closure/07-01-EVIDENCE.md`
- **Verification:** Evidence file includes reproducible command lines and output snapshots.
- **Committed in:** `6b2f5f7`

---

**Total deviations:** 1 environment-constrained verification deviation
**Impact on plan:** Implementation completed; authoritative requirement closure intentionally deferred to Plan 07-03.

## Issues Encountered
- Nix command execution constraints in this runtime limited eval/build verification parity.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- OpenClaw secret path is runtime-only with anti-regression evidence recorded.
- Ready for Plan 07-03 to integrate this evidence into authoritative verification and milestone audit reconciliation.

---
*Phase: 07-secrets-gap-closure*
*Completed: 2026-02-26*
