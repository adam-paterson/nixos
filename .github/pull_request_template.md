## Summary

<!-- Describe what changed and why. -->

## Validation

<!-- List key commands or checks you ran. -->

## Lockfile Governance (`flake.lock`)

- [ ] `flake.lock` unchanged in this PR.
- [ ] `flake.lock` changed intentionally and I documented why.

If `flake.lock` changed, complete all items below:

- [ ] Targeted input(s): `<input-name>` (for example: `nixpkgs`, `home-manager`)
- [ ] Scoped command used: `just lock-update <input-name>` (or equivalent single-input update)
- [ ] Diff scope reviewed with `git diff -- flake.lock` and contains only intended/transitive changes
- [ ] Post-update validation evidence included:
      - `just ci`
      - `just lock-verify`

Policy reference: `docs/flake-lock-workflow.md`
