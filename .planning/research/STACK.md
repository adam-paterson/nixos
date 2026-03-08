# Technology Stack

**Project:** Unified MacBook + Hetzner VPS Nix infrastructure
**Researched:** 2026-02-24
**Scope:** Stack dimension (greenfield milestone)
**Overall confidence:** MEDIUM-HIGH

## Recommended Stack (2026 Opinionated Baseline)

### Core Platform and Flake Foundation

| Technology | Version/Channel | Purpose | Why this choice | Confidence |
|---|---|---|---|---|
| Nix + Flakes | Nix stable (2.28+ behavior documented), flake lock pinned in-repo | Reproducible builds and deployment graph | Flakes are the shared interface for cross-host outputs, checks, and deployment artifacts; lock file gives deterministic inputs | HIGH |
| Nixpkgs | `nixos-25.11` for Linux + Darwin package set; optional narrow `nixos-unstable` overlay for specific packages only | Primary package/module source | 25.11 is current stable and supported through 2026-06-30; gives stability while preserving targeted freshness | HIGH |
| flake-parts | Current pinned input | Structure large flake into modules (`perSystem`, reusable parts) | Better long-term structure and module composition than custom glue; fits multi-host mono-repo growth | HIGH |

### Host Modeling (MacBook + VPS)

| Technology | Version/Channel | Purpose | Why this choice | Confidence |
|---|---|---|---|---|
| nix-darwin | Pin current branch commit in `flake.lock` (follow `nixpkgs`) | Declarative macOS system config | Standard way to model macOS as Nix modules; same repo model as NixOS | HIGH |
| NixOS module system | From `nixos-25.11` | Declarative VPS system config | Native NixOS approach for reliable host rebuilds and rollbacks | HIGH |
| Home Manager (as module) | `release-25.11` aligned with nixpkgs branch | User-level config shared across macOS and NixOS | One user config model across both hosts; `useGlobalPkgs` reduces drift and extra eval | HIGH |

**Prescriptive host pattern**

- Keep host definitions explicit: `darwinConfigurations.<macbook-hostname>` and `nixosConfigurations.<vps-hostname>`.
- Use layered modules: `modules/common` -> `modules/roles/{workstation,server}` -> `hosts/<host>/default.nix`.
- Keep host metadata in one typed attrset (`hosts.nix`): `system`, `targetHost`, `targetUser`, `tags`, `roles`.
- Share only true invariants in `common`; do not over-normalize host differences early.

### Secrets

| Technology | Version/Channel | Purpose | Why this choice | Confidence |
|---|---|---|---|---|
| sops-nix + age | Current pinned inputs (`sops-nix` + `age`) | Encrypted secrets in Git, decrypted at activation | Works on NixOS, nix-darwin, and Home Manager; activation-time decryption avoids plaintext in store; strong team workflow | HIGH |

**Prescriptive secrets pattern**

- Use `age` keys (not GPG) as default for lower operational friction.
- Commit encrypted files under `secrets/` plus `.sops.yaml` policy at repo root.
- On NixOS VPS, use host SSH Ed25519 key conversion (`sops.age.sshKeyPaths`) for bootstrap.
- On macOS, use sops-nix darwin/home-manager modules for user and workstation secrets.

### Provisioning and Deployment Workflows

| Workflow | Tooling | Why this choice | Confidence |
|---|---|---|---|
| First install / reprovision VPS | `nixos-anywhere` + `disko` | Standard unattended remote install pattern for Hetzner-like hosts; declarative disk layout and install path | HIGH |
| Day-2 VPS deploys | `deploy-rs` | Flake-native deploys, profile-level deploy model, rollback protections, deploy checks integration | HIGH |
| Day-2 macOS applies | `darwin-rebuild switch --flake .#<host>` | Native, simple, local workflow for workstation convergence | HIGH |

**Prescriptive deployment commands**

- Bootstrap VPS: `nix run github:nix-community/nixos-anywhere -- --flake .#<vps-host> root@<ip>`
- Deploy VPS: `nix run github:serokell/deploy-rs -- .#<vps-host>.system`
- Apply macOS: `darwin-rebuild switch --flake .#<macbook-host>`

### Testing and Validation Stack

| Layer | Tooling | Required policy | Confidence |
|---|---|---|---|
| Structural/eval checks | `nix flake check` + deploy-rs `deployChecks` in `checks` output | Every PR must pass | HIGH |
| Formatting | `nix fmt` wired to `formatter` output | Every PR must be formatted | HIGH |
| Build checks | `nix build .#nixosConfigurations.<vps>.config.system.build.toplevel` and `nix build .#darwinConfigurations.<mac>.system` | Required in CI on every PR | MEDIUM |
| Lock hygiene | `flake-checker` (CLI or GitHub Action) | Warn or fail when nixpkgs is stale/unsupported | MEDIUM |

### CI and Binary Cache

| Technology | Version | Purpose | Why this choice | Confidence |
|---|---|---|---|---|
| GitHub Actions | Hosted runners (`ubuntu-latest`, optional `macos-latest`) | CI orchestration | Standard CI path for Nix projects and easy branch protection integration | HIGH |
| `cachix/install-nix-action` | `v31` | Install Nix quickly and consistently in CI | Current action docs and maintained path for Nix on Actions | HIGH |
| `cachix/cachix-action` | `v15` | Pull/push binary cache for fast CI and team reuse | Reduces repeat builds and improves feedback time significantly | HIGH |

**Prescriptive CI jobs**

1. `check` (ubuntu): `nix flake check`, deploy checks, lock checker.
2. `build-linux` (ubuntu): build VPS toplevel.
3. `build-darwin` (macos): build Mac toplevel (can be required for main, optional for PR if cost-sensitive).

## Alternatives Considered (and Why Not)

| Category | Recommended | Alternative | Why Not (for this project) |
|---|---|---|---|
| Flake composition | flake-parts | flake-utils | flake-utils is stable but largely static (latest tagged release is old); flake-parts has stronger module-oriented scaling for infra repos |
| Deploy orchestration | deploy-rs | Colmena | Colmena shines for larger NixOS fleets and parallel fan-out; this scope is 1 VPS + 1 MacBook, so deploy-rs is simpler and enough |
| Secret management | sops-nix + age | agenix | agenix is valid, but sops-nix has broader module integration (NixOS + nix-darwin + Home Manager) and richer team workflows |
| Config source style | Flakes + lockfile | Channels (`nix-channel`) | Channel-based workflows increase drift and reduce reproducibility in multi-host repos |

## What Not to Use (Explicit Anti-Recommendations)

- Do not mix multiple secret frameworks in MVP (pick `sops-nix` only).
- Do not run broad `nixos-unstable` as primary branch for both hosts in this scope; use stable base + selective unstable packages.
- Do not start with Colmena/NixOps-style fleet abstraction for a single VPS; adds indirection without payoff.
- Do not keep host-specific values scattered across many files; centralize host inventory metadata.

## Minimum `flake.nix` Input Set

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    sops-nix.url = "github:Mic92/sops-nix";

    deploy-rs.url = "github:serokell/deploy-rs";
    disko.url = "github:nix-community/disko";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  };
}
```

## Source Notes and Confidence

| Claim Area | Confidence | Evidence basis |
|---|---|---|
| 25.11 as current stable baseline | HIGH | Official NixOS 25.11 release announcement and channel status |
| nix-darwin + Home Manager module approach | HIGH | nix-darwin README and Home Manager manual (`nix-darwin module`, `useGlobalPkgs`) |
| sops-nix as cross-platform secrets baseline | HIGH | sops-nix README: NixOS, nix-darwin, Home Manager support; activation-time decryption |
| deploy-rs for small flake-based deploys | HIGH | deploy-rs README: flake-native deploys, rollback and deployChecks |
| GitHub Actions + Cachix stack | HIGH | install-nix-action, cachix-action, nix.dev CI guide |
| flake-parts over flake-utils for new infra repos | MEDIUM | flake-parts docs (module-centric) + flake-utils release staleness indicator |

## Sources

- https://nixos.org/blog/announcements/2025/nixos-2511/ (HIGH)
- https://channels.nixos.org/nixos-25.11 (HIGH)
- https://github.com/nix-darwin/nix-darwin (HIGH)
- https://nix-community.github.io/home-manager/index.xhtml (HIGH)
- https://flake.parts (HIGH)
- https://github.com/hercules-ci/flake-parts (HIGH)
- https://github.com/numtide/flake-utils (MEDIUM)
- https://github.com/Mic92/sops-nix (HIGH)
- https://github.com/serokell/deploy-rs (HIGH)
- https://github.com/zhaofengli/colmena (MEDIUM)
- https://github.com/nix-community/nixos-anywhere (HIGH)
- https://github.com/nix-community/disko (HIGH)
- https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake-check (HIGH)
- https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-fmt (HIGH)
- https://nix.dev/tutorials/continuous-integration-github-actions (MEDIUM)
- https://github.com/cachix/install-nix-action (HIGH)
- https://github.com/cachix/cachix-action (HIGH)
- https://github.com/DeterminateSystems/flake-checker (MEDIUM)
