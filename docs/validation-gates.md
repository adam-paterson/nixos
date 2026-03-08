# Validation Gates: Required Merge Policy

This repository treats `Nix Checks` as the merge gate for `main`.

## Required Gate Contract

The required status check must enforce the single CI workflow contract:

- Workflow: `Nix Checks`
- Required check context (common): `Nix Checks / Lint And Eval`

`Nix Checks` must cover:

- `Format Check`
- `Lint`
- `Flake Checks`
- `Evaluate Configurations`
- `Host Contract Dry Build`
- `Secrets Scan`

If any stage fails, merge eligibility must be blocked until a passing run exists for the latest commit.

## Verify Enforcement (GitHub CLI/API)

Set target repository:

```bash
OWNER_REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
```

Check branch protection required statuses:

```bash
gh api "repos/<owner>/<repo>/branches/main/protection/required_status_checks"
gh api "repos/${OWNER_REPO}/branches/main/protection/required_status_checks"
```

Check rulesets that can enforce required status checks:

```bash
gh api "repos/${OWNER_REPO}/rulesets"
```

Inspect ruleset payload and verify:

- `enforcement` is `active` for rules targeting branch `main`
- A required status checks rule includes `Nix Checks` or `Nix Checks / Lint And Eval`
- No bypass actor/policy allows unreviewed failed-check merges for normal contributors

## Expected Pass/Fail Behavior

- Pass case: a PR commit with a successful `Nix Checks` run can become merge-eligible (subject to other repository policies).
- Fail case: a PR commit with failed `Nix Checks` must remain non-mergeable.
- Missing-check case: if no `Nix Checks` context is reported for the head commit, merge must remain blocked.

## Misconfiguration Detection

Treat configuration as unsafe if any of the following are true:

- `required_status_checks` is disabled or empty for `main` branch protection, and no equivalent active ruleset exists.
- Required checks do not include `Nix Checks` or `Nix Checks / Lint And Eval`.
- Ruleset enforcement is `disabled` / not `active` for target branch scope.
- Bypass actors include overly broad principals (for example, everyone with write access).

If unsafe, update branch protection/rulesets so the `Nix Checks` status is mandatory before merge.
