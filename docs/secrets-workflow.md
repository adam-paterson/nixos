# Secrets Workflow

This repository treats 1Password as the master source for secret values.
Git stores only encrypted SOPS files and explicit non-secret placeholders.

## Setup Checklist

1. Install required CLIs: `op`, `sops`, `age`, `just`.
2. Authenticate 1Password for your current shell:
   - interactive: run `op signin`
   - automation/headless: export `OP_SERVICE_ACCOUNT_TOKEN`
3. Verify auth is available: `just secrets-auth-preflight`
4. Confirm placeholder-only templates are intact: `secrets/templates/env.example`
5. Run safety checks before editing or committing: `just secrets-scan`

## Secret Boundaries

- Shared keys: `secrets/shared/common.yaml`
- Aurora-only keys: `secrets/hosts/aurora.yaml`
- MacBook-only keys: `secrets/hosts/macbook.yaml`
- Dummy onboarding placeholders only: `secrets/templates/env.example`

Keep values encrypted in these SOPS files. Do not commit plaintext `.env` files, API tokens, private keys, or credential JSON blobs.

## Runtime-Only Decryption Contract

Decryption is allowed only in apply/deploy flows:

- `just secrets-apply-macbook`
- `just secrets-deploy-aurora`

Both wrappers run `just secrets-auth-preflight` first and fail hard when authentication is unavailable. There are no fallback defaults for required secrets.

## Canonical Commands

### Secret Maintenance

- Edit encrypted shared secrets: `just secrets-edit-shared`
- Edit encrypted Aurora secrets: `just secrets-edit-aurora`
- Edit encrypted MacBook secrets: `just secrets-edit-macbook`
- Re-encrypt to current recipients: `just secrets-updatekeys`

### Guardrails and Mock-Safe Validation

- Scan changed files for plaintext leaks: `just secrets-scan`
- Run non-secret eval/dry-build checks without real credentials: `just secrets-mock-check`

`just secrets-mock-check` validates non-secret evaluation and dry-build surfaces while keeping secret values out of evaluation inputs.

## Troubleshooting

### `1Password authentication missing...`

- Run `op signin` for local interactive use, or export `OP_SERVICE_ACCOUNT_TOKEN` for headless sessions.
- Re-run `just secrets-auth-preflight`.

### `Secret scan failed...`

- Move sensitive values into encrypted SOPS files.
- Keep only encrypted payload markers or `DUMMY_NOT_A_SECRET_*` placeholders in tracked files.
- Re-run `just secrets-scan`.

### Missing required runtime secret during apply/deploy

- Confirm the required key exists in the correct encrypted file (shared vs host-specific).
- Update encrypted file via the `just secrets-edit-*` wrappers.
- Retry apply/deploy explicitly after fixing the encrypted source file.
