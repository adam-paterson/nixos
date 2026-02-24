# Domain Pitfalls

**Domain:** Nix-based workstation + server infrastructure repository (nix-darwin + NixOS + flakes)
**Researched:** 2026-02-24

## Critical Pitfalls

Mistakes that usually force rollback-heavy incidents, hidden drift, or expensive refactors.

### Pitfall 1: Treating `flake.lock` updates as routine instead of controlled change windows
**What goes wrong:** Workstation and VPS both move dependency graph unexpectedly; one host breaks while the other appears fine.
**Why it happens:** Teams run broad `nix flake update` frequently, without input-by-input review and host-specific validation.
**Consequences:** Cross-host drift, failed rebuilds after merge, emergency pinning/reverts.
**Prevention:**
- Pin everything in `flake.lock` and review lock diffs as first-class code changes.
- Prefer targeted updates (`nix flake update <input>`) and batch by risk domain (base system, apps, secrets, deploy tooling).
- Add a CI gate that runs `nix flake check` and target evaluations for both `aarch64-darwin` and server `x86_64-linux` before merge.
**Detection / warning signs:**
- Large lock-file churn in one PR with no rationale.
- "Worked on laptop, failed on VPS" after the same merge.
- Frequent hotfix commits that only re-pin inputs.
**Phase mapping recommendation:** Foundation phase. Lock/update policy must exist before module expansion.
**Confidence:** HIGH

### Pitfall 2: Flake source blind spots (files not actually included in evaluation/deploy)
**What goes wrong:** Build or deploy fails because a referenced module/file is missing in the flake source snapshot.
**Why it happens:** In Git repos, flake workflows commonly rely on tracked files; new files are created but not tracked/staged as expected.
**Consequences:** Broken deploys at the worst time, confusing "file not found in /nix/store/...-source" failures.
**Prevention:**
- Enforce pre-commit checks that evaluate all host outputs.
- Keep host/module trees simple and avoid dynamic path tricks for core imports.
- Add a contributor rule: new module files must be tracked before testing/deploy.
**Detection / warning signs:**
- Errors referencing missing files under `/nix/store/*-source`.
- New modules work locally in editor but fail during flake-based commands.
- Repeated "why can't rebuild see this file?" incidents.
**Phase mapping recommendation:** Repository-structure phase. Define import conventions and contributor workflow early.
**Confidence:** HIGH

### Pitfall 3: Letting secrets leak into the Nix store or evaluation graph
**What goes wrong:** Secrets become readable by unintended users or embedded into store paths/logging history.
**Why it happens:** Plaintext secrets are committed, or secrets are read during evaluation (`builtins.readFile` anti-pattern) instead of runtime decryption.
**Consequences:** Credential exposure, incident response/rotation overhead, trust loss in repo.
**Prevention:**
- Adopt one runtime secret system up front (sops-nix or agenix) and ban plaintext secrets in repo.
- Enforce runtime secret consumption (`/run/secrets` or `/run/agenix`) and prohibit eval-time reads in reviews.
- Add secret scanning plus policy checks in CI.
**Detection / warning signs:**
- Presence of API keys/passwords in `.nix`, `.env`, or generated files under version control.
- Config expressions reading secret files directly during evaluation.
- Team uncertainty on "where secrets live" across darwin vs VPS.
**Phase mapping recommendation:** Security baseline phase before first real deployment.
**Confidence:** HIGH

### Pitfall 4: Cross-platform module coupling (Darwin and NixOS concerns mixed without boundaries)
**What goes wrong:** Shared modules accidentally depend on Linux-only or macOS-only options; one side continuously breaks.
**Why it happens:** Early repo organization optimizes for DRY too aggressively, before clear OS boundaries exist.
**Consequences:** Fragile evaluations, unreadable conditional logic, slower onboarding/maintenance.
**Prevention:**
- Define strict module layers: `shared/` (truly portable), `darwin/`, `nixos/`, `host/`.
- Keep platform conditionals shallow; prefer platform-specific modules over giant `if pkgs.stdenv.isDarwin then ...` blocks.
- Add separate eval/build jobs per platform in CI.
**Detection / warning signs:**
- Frequent option-not-found errors on one platform.
- Shared modules containing many nested platform checks.
- Small changes to one host unexpectedly touching both hosts.
**Phase mapping recommendation:** Architecture phase, immediately after foundation conventions.
**Confidence:** HIGH

### Pitfall 5: No safe deployment path (test/switch discipline + rollback drills missing)
**What goes wrong:** First bad deploy to VPS requires manual repair because rollback behavior and connectivity safeguards were never exercised.
**Why it happens:** Teams jump from local `switch` success to remote production changes without staged checks.
**Consequences:** Avoidable downtime, lockout risk, high-stress emergency access.
**Prevention:**
- Standardize deployment sequence and failure handling (evaluate -> build -> test -> switch).
- If using deploy tooling, keep safety features enabled (for example deploy-rs rollback protections) and validate them in non-prod.
- Document and rehearse generation rollback on the server.
**Detection / warning signs:**
- No written runbook for failed deploys.
- "We have rollback" but nobody has practiced it.
- Production changes applied directly from ad-hoc local commands.
**Phase mapping recommendation:** Deployment-hardening phase before routine VPS updates.
**Confidence:** MEDIUM-HIGH

### Pitfall 6: Misusing `system.stateVersion` during upgrades
**What goes wrong:** Operators bump `system.stateVersion` to "upgrade faster" and trigger incompatible state/data defaults.
**Why it happens:** Confusion between release channel/flake input upgrades and state compatibility versioning.
**Consequences:** Service migration breakage, data compatibility incidents, difficult rollback.
**Prevention:**
- Treat `system.stateVersion` as install-era compatibility marker; do not change casually.
- Add explicit upgrade playbooks that separate package upgrades from state migrations.
- Require migration notes in PRs when any state-version-adjacent change is proposed.
**Detection / warning signs:**
- PRs that change `system.stateVersion` without migration plan.
- Team language like "bump stateVersion to get newest packages".
- Post-upgrade service data errors after seemingly simple release bump.
**Phase mapping recommendation:** Upgrade-policy phase before first major release jump.
**Confidence:** HIGH

## Moderate Pitfalls

### Pitfall 1: Home Manager and Nixpkgs release skew
**What goes wrong:** Home-manager modules or options fail unexpectedly after updates.
**Prevention:** Keep Home Manager release branch aligned with target NixOS/nixpkgs release line; codify update pairings in policy.
**Warning signs:** Option breakage right after lock updates; frequent HM-only fixes.
**Phase mapping recommendation:** Dependency-policy phase.
**Confidence:** HIGH

### Pitfall 2: Treating flakes as fully stable contracts
**What goes wrong:** Tooling assumptions break across Nix upgrades because flake CLI behavior is still marked experimental.
**Prevention:** Pin Nix version in dev/deploy environments and test CLI workflow before bumping Nix itself.
**Warning signs:** CI/deploy scripts brittle to Nix minor updates.
**Phase mapping recommendation:** Toolchain-pinning phase.
**Confidence:** HIGH

## Minor Pitfalls

### Pitfall 1: Over-abstracting too early
**What goes wrong:** New repo gets framework-like indirection before real usage patterns are known.
**Prevention:** Keep first iteration explicit per-host; extract only repeated, proven patterns.
**Warning signs:** New contributors cannot trace where a single setting is defined/applied.
**Phase mapping recommendation:** Ongoing governance after MVP.
**Confidence:** MEDIUM

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Foundation (flake + lock + CI skeleton) | Uncontrolled input churn | Lockfile policy, targeted updates, mandatory `nix flake check` |
| Repo structure and module boundaries | Darwin/NixOS coupling | Explicit layer boundaries (`shared`/`darwin`/`nixos`/`hosts`) |
| Secrets baseline | Secrets in store/evaluation | sops-nix or agenix from day 1, ban eval-time secret reads |
| Deployment workflow | Remote lockout or failed switch | Staged deploy runbook, rollback rehearsal, safety flags enabled |
| Upgrade management | `stateVersion` misuse | Separate state migration policy from package/version updates |

## Sources

- Nix reference: `nix flake lock` and `nix flake update` semantics, and experimental status warnings (HIGH):
  - https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-lock
  - https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-update
- Nix reference: `nix flake check` for evaluation/build checks (HIGH):
  - https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-check
- nix.dev tutorial: flake/git-tracked behavior and world-readable store cautions (HIGH):
  - https://nix.dev/tutorials/working-with-local-files.html
- Home Manager README: release branch alignment guidance (HIGH):
  - https://raw.githubusercontent.com/nix-community/home-manager/master/README.md
- nix-darwin README: flakes recommendation and platform setup caveats (HIGH):
  - https://raw.githubusercontent.com/LnL7/nix-darwin/master/README.md
- deploy-rs README: rollback safety model (`magicRollback`, `autoRollback`) (MEDIUM-HIGH):
  - https://raw.githubusercontent.com/serokell/deploy-rs/master/README.md
- agenix README: Nix store secret risks and eval-time `builtins.readFile` anti-pattern (HIGH):
  - https://raw.githubusercontent.com/ryantm/agenix/main/README.md
- sops-nix README: activation-time decryption model and deployment caveats (HIGH):
  - https://raw.githubusercontent.com/Mic92/sops-nix/master/README.md
- `system.stateVersion` option explanation (sourced from nixpkgs declarations; MEDIUM):
  - https://mynixos.com/nixpkgs/option/system.stateVersion
