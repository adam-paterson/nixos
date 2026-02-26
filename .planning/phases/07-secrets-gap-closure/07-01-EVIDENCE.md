# 07-01 Raw Implementation Evidence

Date: 2026-02-26
Plan: `07-secrets-gap-closure/07-01-PLAN.md`
Scope: Runtime-only OpenClaw secret wiring evidence and anti-regression output capture.

## Command: SOPS runtime secret path eval

```bash
nix eval .#homeConfigurations."adam@aurora".config.sops.secrets."hosts/aurora/openclaw/gateway_auth_token".path
```

```text
warning: unknown setting 'eval-cores'
warning: unknown setting 'lazy-trees'
error:
       … while fetching the input 'git+file:///Users/adampaterson/Projects/nixos-config'

       error: executing SQLite statement 'pragma synchronous = off': unable to open database file, unable to open database file (in '/Users/adampaterson/.cache/nix/fetcher-cache-v4.sqlite')
```

## Command: Home Manager activation dry-run

```bash
nix build --dry-run .#homeConfigurations."adam@aurora".activationPackage
```

```text
warning: unknown setting 'eval-cores'
warning: unknown setting 'lazy-trees'
error:
       … while fetching the input 'git+file:///Users/adampaterson/Projects/nixos-config'

       error: executing SQLite statement 'pragma synchronous = off': unable to open database file, unable to open database file (in '/Users/adampaterson/.cache/nix/fetcher-cache-v4.sqlite')
```

## Command: Anti-regression grep for OpenClaw token literal patterns

```bash
rg -n --hidden --glob '!*.age' --glob '!*.yaml' 'gateway_auth_token|OPENCLAW|token\s*=\s*"' src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix src/modules/home/security/secrets/default.nix
```

```text
src/modules/home/security/secrets/default.nix:10:  openclawGatewaySecretName = "hosts/aurora/openclaw/gateway_auth_token";
src/modules/home/security/secrets/default.nix:100:      OPENCLAW_GATEWAY_AUTH_TOKEN_FILE =
src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix:3:  tokenFilePath = config.home.sessionVariables.OPENCLAW_GATEWAY_AUTH_TOKEN_FILE;
src/homes/x86_64-linux/adam@aurora/programs/openclaw/default.nix:11:        Ensure OPENCLAW_GATEWAY_AUTH_TOKEN_FILE is exported from Home Manager secrets wiring.
```

## Notes

- OpenClaw config consumes runtime secret path via `tokenFile = tokenFilePath` and contains no plaintext `token = "..."` literal.
- This file captures raw execution evidence only. Authoritative requirement-status updates are deferred to Plan `07-03`.
