---
phase: 04-secrets-safe-configuration
plan: 02
subsystem: infra
tags: [sops-nix, sops, nixos, nix-darwin, home-manager]

requires:
  - phase: 04-secrets-safe-configuration
    provides: encrypted secret artifacts and SOPS policy scaffolding
provides:
  - Runtime-only secret module wiring for NixOS, nix-darwin, and Home Manager
  - Collection-level defaults that enable secret handling without host policy sprawl
  - Aurora host consumption of cloudflared credentials via config.sops.secrets path
affects: [phase-04-plan-03, validation, deploy]

tech-stack:
  added: []
  patterns:
    - sops-nix module imports per target layer
    - runtime file-path secret consumption via config.sops.secrets.<key>.path
    - host-scoped fail-hard assertions for required secret declarations

key-files:
  created:
    - src/modules/nixos/security/secrets/default.nix
    - src/modules/darwin/security/secrets/default.nix
    - src/modules/home/security/secrets/default.nix
  modified:
    - src/modules/nixos/collections/server/default.nix
    - src/modules/darwin/collections/workstation/default.nix
    - src/modules/home/collections/base/default.nix
    - src/systems/x86_64-linux/aurora/default.nix

key-decisions:
  - "Use inputs.self-based secret file paths so sops files resolve correctly under Snowfall's src-rooted module evaluation."
  - "Set a Home Manager default age key file path to satisfy sops-nix key-source assertions during evaluation."

patterns-established:
  - "Secrets modules should declare required keys and fail with explicit host/user diagnostics."
  - "Secret consumers must read runtime paths, not static plaintext-oriented file locations."

requirements-completed: [SECR-01, SECR-02]

duration: 15 min
completed: 2026-02-25
---

# Phase 4 Plan 02: Runtime Secret Path Wiring Summary

**Runtime-only secret wiring now spans NixOS, nix-darwin, and Home Manager, with aurora consuming cloudflared credentials strictly from `config.sops.secrets` runtime paths.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-02-25T10:28:57Z
- **Completed:** 2026-02-25T10:44:16Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- Added dedicated secrets modules for NixOS, Darwin, and Home Manager that import `sops-nix` and declare host/user-scoped required keys.
- Enabled all secrets modules through collection defaults (`mkDefault true`) so secure runtime wiring is inherited by composition boundaries.
- Switched aurora cloudflared credentials to `config.sops.secrets."hosts/aurora/cloudflared/credentials_json".path`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add runtime-only secrets modules for NixOS, Darwin, and Home Manager** - `1f22ccc` (feat)
2. **Task 2: Enable secrets modules through existing collection boundaries** - `fa07f29` (feat)
3. **Task 3: Replace direct host secret file references with runtime secret paths** - `7bad2e3` (feat)

**Plan metadata:** pending final docs commit

## Files Created/Modified
- `src/modules/nixos/security/secrets/default.nix` - NixOS runtime secret declarations and host-scoped required-key assertions.
- `src/modules/darwin/security/secrets/default.nix` - Darwin runtime secret declarations and host-scoped required-key assertions.
- `src/modules/home/security/secrets/default.nix` - Home Manager runtime secret declarations and `_FILE` session variable exports.
- `src/modules/nixos/collections/server/default.nix` - Enables NixOS secrets module via collection default.
- `src/modules/darwin/collections/workstation/default.nix` - Enables Darwin secrets module via collection default.
- `src/modules/home/collections/base/default.nix` - Enables Home Manager secrets module via collection default.
- `src/systems/x86_64-linux/aurora/default.nix` - Uses runtime secret path for cloudflared credentials.

## Decisions Made
- Used `inputs.self + "/secrets/..."` for sops file references to keep secrets resolvable under flake evaluation with `snowfall.root = ./src`.
- Added `sops.age.keyFile` default in Home Manager to avoid key-source assertion failures during `nix eval`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Relative secret file paths broke under Snowfall src-rooted flake evaluation**
- **Found during:** Task 1
- **Issue:** Initial relative `sopsFile` paths resolved to missing paths in pure eval.
- **Fix:** Replaced relative paths with `inputs.self + "/secrets/..."` for all target modules.
- **Files modified:** `src/modules/nixos/security/secrets/default.nix`, `src/modules/darwin/security/secrets/default.nix`, `src/modules/home/security/secrets/default.nix`
- **Verification:** `nix eval` succeeded for NixOS, Darwin, and Home Manager `config.sops.secrets` outputs.
- **Committed in:** `1f22ccc` (part of Task 1 commit)

**2. [Rule 3 - Blocking] Home Manager sops-nix required explicit key source during eval**
- **Found during:** Task 1
- **Issue:** Home configuration evaluation failed with "No key source configured for sops".
- **Fix:** Set `sops.age.keyFile` default to `${config.home.homeDirectory}/.config/sops/age/keys.txt`.
- **Files modified:** `src/modules/home/security/secrets/default.nix`
- **Verification:** Home Manager `nix eval` of `config.sops.secrets` succeeded.
- **Committed in:** `1f22ccc` (part of Task 1 commit)

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both fixes were required to complete planned verification without changing scope.

## Issues Encountered
None.

## User Setup Required

**External services require manual configuration.**
- Set `OP_SERVICE_ACCOUNT_TOKEN` from 1Password Service Accounts for runtime retrieval flows.
- Ensure required encrypted keys exist in 1Password-backed SOPS files referenced by this phase.

## Next Phase Readiness
- Runtime secret path wiring is in place for macbook and aurora with host-scoped fail-hard declarations.
- Ready for 04-03 guardrails (plaintext leak checks and workflow documentation).

---
*Phase: 04-secrets-safe-configuration*
*Completed: 2026-02-25*

## Self-Check: PASSED

- FOUND: `.planning/phases/04-secrets-safe-configuration/04-02-SUMMARY.md`
- FOUND commits: `1f22ccc`, `fa07f29`, `7bad2e3`
