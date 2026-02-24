## Deferred Items

- `03-01` verification gap: `nix build .#homeConfigurations."adam@aurora".activationPackage` cannot be fully built from this `aarch64-darwin` executor when uncached `x86_64-linux` derivations are required. Validation proceeded with `nix build --dry-run` for eval-level coverage plus repo contract checks.
- `03-02` verification refresh observed the same platform constraint while re-running direct `nix build` checks for `adam@aurora`; command contract evidence was recorded in `03-VERIFICATION.md` with `--dry-run` validation on this host.
