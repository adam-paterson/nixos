# Flake Lock Workflow

This repository treats `flake.lock` as the source of truth for dependency
revisions. Day-to-day work should verify lock integrity without mutating the
graph. Dependency updates are an explicit maintenance action with reviewable
diffs.

## Verify Path (No Lock Updates)

Use this path during normal feature work and before commits:

1. Verify lock consistency without writing `flake.lock`:

   ```bash
   nix flake lock --no-update-lock-file
   ```

2. Confirm no lock mutation occurred:

   ```bash
   git diff -- flake.lock
   ```

Expected result: no diff.

## Update Path (Intentional Changes)

Use this path only when intentionally changing inputs.

1. Sync lock entries for existing `flake.nix` input declarations:

   ```bash
   nix flake lock
   ```

2. Update one input in scope:

   ```bash
   nix flake update --update-input <input-name>
   ```

3. Review `flake.lock` changes before commit:

   ```bash
   git diff -- flake.lock
   ```

## Lock Diff Review Checklist

- Diff only includes intended input(s) and expected transitive dependency moves.
- No unrelated broad lock churn is present.
- `nix flake lock --no-update-lock-file` still succeeds after updates.
- Any impact on builds/eval is verified through normal repo checks.

## Anti-Patterns to Avoid

- Running broad `nix flake update` during unrelated feature work.
- Committing large `flake.lock` diffs without scoped intent.
- Treating lock updates as incidental side effects instead of explicit changes.
- Skipping diff review of `flake.lock` before merge.
