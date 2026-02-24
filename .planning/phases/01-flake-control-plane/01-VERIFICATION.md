---
phase: 01-flake-control-plane
verified: 2026-02-24T14:59:43Z
status: passed
score: 6/6 must-haves verified
---

# Phase 1: Flake Control Plane Verification Report

**Phase Goal:** Users can deterministically evaluate and build both managed targets from one pinned flake.
**Verified:** 2026-02-24T14:59:43Z
**Status:** passed
**Re-verification:** No - initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | User can enumerate configured Darwin and NixOS hosts directly from flake outputs. | ✓ VERIFIED | `src/shells/common/default.nix:24` and `src/shells/common/default.nix:50` define `list_hosts()` with `nix eval ... builtins.attrNames`; used for both `darwinConfigurations` and `nixosConfigurations` at `src/shells/common/default.nix:40-41` and `src/shells/common/default.nix:68-69`. |
| 2 | User can run one contract check that evaluates every declared host without host-local setup. | ✓ VERIFIED | `flake-contract.exec` loops discovered hosts and evaluates each target in one command path (`src/shells/common/default.nix:47-73`), and hook parity is wired via `nix develop "path:$PWD#ci" -c flake-contract` in `src/shells/dev/default.nix:35`. |
| 3 | User can dry-build both Darwin and NixOS system targets from the same flake graph. | ✓ VERIFIED | `nix build --dry-run` is executed for Darwin (`...system`) and NixOS (`...config.system.build.toplevel`) within the same `flake-contract.exec` flow at `src/shells/common/default.nix:64` and `src/shells/common/default.nix:71-72`. |
| 4 | User can distinguish lockfile integrity checks from intentional dependency updates. | ✓ VERIFIED | Policy explicitly separates Verify Path vs Update Path in `docs/flake-lock-workflow.md:8` and `docs/flake-lock-workflow.md:26`; commands are split into `lock-verify`, `lock-sync`, and `lock-update` in `Justfile:36-46`. |
| 5 | User can run deterministic lock verification commands and get reproducible results across environments. | ✓ VERIFIED | `lock-verify` uses `nix flake lock --no-update-lock-file` plus pre/post `flake.lock` hash equality check in `Justfile:36-40`; same workflow is documented in `README.md:153-169`. |
| 6 | User can perform controlled input updates with reviewable `flake.lock` diffs. | ✓ VERIFIED | Scoped update command is documented (`nix flake update --update-input <input-name>`) and lock diff review is required in `docs/flake-lock-workflow.md:36-46`; `just lock-update <input>` maps directly at `Justfile:45-46`. |

**Score:** 6/6 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `src/shells/common/default.nix` | Deterministic host-matrix eval and dry-build scripts for all configured hosts | ✓ VERIFIED | Exists, substantive implementation (`eval.exec` + `flake-contract.exec`), and wired into shells via `import ../common` in `src/shells/dev/default.nix:13` and `src/shells/ci/default.nix:13`. |
| `src/shells/dev/default.nix` | Local guardrail hook that runs the same flake contract check | ✓ VERIFIED | Exists, substantive hook config (`git-hooks.hooks.flake-eval`), wired to CI shell contract command at `src/shells/dev/default.nix:30-36`. |
| `docs/flake-lock-workflow.md` | Explicit lockfile policy and command workflow for deterministic revisions | ✓ VERIFIED | Exists, substantive verify/update/checklist/anti-pattern sections (`docs/flake-lock-workflow.md:8-60`), referenced from README (`README.md:158`). |
| `Justfile` | Callable lock verification and controlled update recipes | ✓ VERIFIED | Exists, substantive executable recipes (`Justfile:36-46`), linked from README command entrypoints (`README.md:161-168`). |
| `README.md` | Operator-facing quickstart for lockfile discipline commands | ✓ VERIFIED | Exists, substantive lock workflow section (`README.md:153-169`) pointing to policy doc and just commands. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `src/shells/common/default.nix` | `path:$PWD#darwinConfigurations` | nix eval attr discovery | ✓ WIRED | Dynamic discovery and contract use found at `src/shells/common/default.nix:40`, `src/shells/common/default.nix:68`, `src/shells/common/default.nix:71`. |
| `src/shells/common/default.nix` | `path:$PWD#nixosConfigurations` | nix eval attr discovery | ✓ WIRED | Dynamic discovery and contract use found at `src/shells/common/default.nix:41`, `src/shells/common/default.nix:69`, `src/shells/common/default.nix:72`. |
| `src/shells/dev/default.nix` | `src/shells/common/default.nix` | pre-commit flake evaluation command | ✓ WIRED | Dev shell imports common module (`src/shells/dev/default.nix:13`) and hook calls `flake-contract` through CI shell (`src/shells/dev/default.nix:35`). |
| `Justfile` | `docs/flake-lock-workflow.md` | recipe names and command semantics | ✓ WIRED | `lock-verify`/`lock-sync`/`lock-update` recipes (`Justfile:36-46`) match documented verify/update policy (`docs/flake-lock-workflow.md:8-46`). |
| `README.md` | `Justfile` | documented command references | ✓ WIRED | README lock section advertises `just lock-verify`, `just lock-sync`, `just lock-update` (`README.md:161-168`). |
| `docs/flake-lock-workflow.md` | `flake.lock` | review process and expected diff scope | ✓ WIRED | Workflow treats `flake.lock` as source of truth and mandates diff review (`docs/flake-lock-workflow.md:3-6`, `docs/flake-lock-workflow.md:21`, `docs/flake-lock-workflow.md:45`). |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `CORE-01` | `01-01-PLAN.md` | User can build both `darwinConfigurations` and `nixosConfigurations` from one flake | ✓ SATISFIED | Dual-target dry-build in single contract command at `src/shells/common/default.nix:71-72` and flake attrs for both targets throughout `src/shells/common/default.nix`. |
| `CORE-02` | `01-02-PLAN.md` | User can reproduce the same dependency graph from a pinned `flake.lock` | ✓ SATISFIED | Non-mutating verify command and checksum guard in `Justfile:36-40`; lock policy and diff review in `docs/flake-lock-workflow.md:8-53`; pinned lockfile exists in `flake.lock`. |
| `CORE-03` | `01-01-PLAN.md` | User can evaluate all configured hosts without manual per-host setup | ✓ SATISFIED | Host discovery loops via `builtins.attrNames` and per-host eval iteration in `src/shells/common/default.nix:24-45` and `src/shells/common/default.nix:50-73`. |

All requirement IDs declared in phase plan frontmatter were accounted for (`CORE-01`, `CORE-02`, `CORE-03`), and each maps to Phase 1 in `.planning/REQUIREMENTS.md:81-83`. No orphaned Phase 1 requirements found.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME/placeholder/empty-handler stubs detected in phase key files (`src/shells/common/default.nix`, `src/shells/dev/default.nix`, `docs/flake-lock-workflow.md`, `Justfile`, `README.md`). | ℹ️ Info | No blocking anti-patterns detected. |

### Human Verification Required

None.

### Gaps Summary

No gaps found. Must-haves are present, substantive, and wired. Phase goal is achieved in code and operational entrypoints.

---

_Verified: 2026-02-24T14:59:43Z_
_Verifier: Claude (gsd-verifier)_
