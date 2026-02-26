# Flake Lock Workflow

This repository treats `flake.lock` as the source of truth for dependency
revisions. The default path is lock verification with zero mutation.
Lock updates are explicit maintenance actions and require a clear intent note,
scoped diffs, and validation evidence.

## Workflow Contract

- Feature PRs should run lock verification only.
- Lock updates must declare target input(s) before running update commands.
- Lock diffs must remain reviewable and scoped to intended change.
- Every intentional lock update must include post-update validation evidence.

## Verify Path (Default, No Lock Updates)

Use this path during normal feature work and before commit/push:

1. Run lock verification:

   ```bash
   just lock-verify
   ```

   Equivalent direct command:

   ```bash
   nix flake lock --no-update-lock-file
   ```

2. Confirm there is no lock mutation:

   ```bash
   git diff -- flake.lock
   ```

Expected result: no diff.

## Update Path (Intentional, Scoped Changes)

Use this path only for deliberate dependency maintenance.

1. Write an intent statement in your PR/work note before updating:
   `Intent: update <input-name> for <reason>.`

2. Ensure lock entries are in sync with declared flake inputs:

   ```bash
   just lock-sync
   ```

3. Update exactly one input in scope:

   ```bash
   just lock-update <input-name>
   ```

   Equivalent direct command:

   ```bash
   nix flake update --update-input <input-name>
   ```

4. Review lock diff before commit:

   ```bash
   git diff -- flake.lock
   ```

5. Run post-update validation and include results in the PR:

   ```bash
   just ci
   just lock-verify
   ```

## Lock Diff Review Checklist

- Declared intent matches changed lock entries.
- Diff only includes targeted input(s) and expected transitive moves.
- No unrelated broad lock churn is present.
- `just ci` passed after update.
- `just lock-verify` passed after update.

## Anti-Patterns to Avoid

- Running broad `nix flake update` during unrelated feature work.
- Updating multiple inputs when only one input change was intended.
- Committing large `flake.lock` diffs without scoped intent and validation output.
- Treating lock updates as incidental side effects instead of explicit changes.
- Skipping `flake.lock` diff review before merge.
