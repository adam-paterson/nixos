# Architecture Patterns

**Domain:** Unified Nix repo for one macOS workstation + one Hetzner NixOS VPS
**Researched:** 2026-02-24

## Recommended Architecture

Use a **single flake as control plane**, with strict layering and host composition at the edge:

```text
repo/
  flake.nix                      # only entrypoint; defines inputs/outputs and host wiring
  flake.lock                     # determinism anchor
  lib/                           # helper functions (mkHost, mkUser, mkChecks)
  modules/
    shared/                      # cross-platform modules (users, shell, git, security baselines)
    darwin/                      # macOS-only nix-darwin modules
    nixos/                       # linux-only NixOS modules
    deploy/                      # deploy-rs node/profile definitions
  hosts/
    macbook/
      default.nix                # host assembly only, no business logic
      hardware.nix               # host-specific facts
    hetzner-vps/
      default.nix                # host assembly only
      disko.nix                  # disk layout (install-time ownership)
      hardware.nix               # generated/static hardware facts
  checks/
    eval.nix                     # flake checks, module eval checks, invariants
  ci/
    checks.nix                   # CI entry targets (nix flake check + host builds)
```

This keeps ownership explicit: **modules define behavior**, **hosts assemble modules**, **flake exports deployable artifacts**.

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `flake.nix` (Control Plane) | Pins dependencies, exposes `darwinConfigurations`, `nixosConfigurations`, `checks`, optional deploy targets | `lib/`, `hosts/`, `modules/`, `checks/` |
| `modules/shared` | Cross-cutting policy (users, shells, common tooling, naming conventions) | Imported by both `hosts/macbook` and `hosts/hetzner-vps` |
| `modules/darwin` | macOS-specific system concerns via nix-darwin | `hosts/macbook`, optional Home Manager nix-darwin module |
| `modules/nixos` | Linux/server concerns via NixOS modules | `hosts/hetzner-vps`, install/deploy tools |
| `hosts/*` | Final composition per machine; sets host facts and selected modules | `modules/*`, `lib/`, `flake.nix` |
| `modules/deploy` (optional but recommended) | Declarative remote activation graph (`deploy-rs` nodes/profiles/order) | `flake.nix`, `nixosConfigurations` |
| `checks/` | Determinism and safety gates (`nix flake check`, eval/build checks) | CI and local pre-deploy workflows |
| `bootstrap` path (`nixos-anywhere` + `disko`) | One-time or reprovision install path for VPS | Consumes `hosts/hetzner-vps` install modules |

### Data Flow

1. `flake.lock` pins all upstreams (primary determinism source).
2. `flake.nix` evaluates inputs and invokes host constructors (`lib/`).
3. Host assembly in `hosts/*` imports shared + platform modules.
4. System derivations are produced:
   - `darwinConfigurations.<mac>.system`
   - `nixosConfigurations.<vps>.config.system.build.toplevel`
5. Validation path runs first (`nix flake check`, host builds).
6. Activation path:
   - macOS: `darwin-rebuild switch --flake .#<mac>`
   - VPS: `deploy-rs` (steady state) or `nixos-anywhere` (bootstrap/rebuild from blank OS)

## Patterns to Follow

### Pattern 1: Thin Host, Fat Module
**What:** Keep host files as composition maps; put logic in reusable modules.
**When:** Always, unless a value is truly host-unique (disk IDs, NIC names, hostname).
**Example:**
```nix
# hosts/hetzner-vps/default.nix
{ inputs, ... }:
{
  imports = [
    ../../modules/shared/base.nix
    ../../modules/shared/users.nix
    ../../modules/nixos/server-base.nix
    ../../modules/nixos/ssh.nix
    ./hardware.nix
    ./disko.nix
  ];
}
```

### Pattern 2: Single `pkgs` Lineage Across Layers
**What:** Use one nixpkgs lineage per host eval; avoid hidden second package sets.
**When:** Especially when integrating Home Manager into NixOS/nix-darwin.
**Example:**
```nix
# Home Manager module integration
home-manager.useGlobalPkgs = true;
```

### Pattern 3: Separate Bootstrap from Day-2 Deploy
**What:** Treat installation and ongoing deployment as different planes.
**When:** VPS lifecycle management.
**Example:**
```text
Bootstrap (day-0): nixos-anywhere + disko -> first NixOS image
Operations (day-2): deploy-rs -> safe incremental activation + rollback
```

### Pattern 4: Policy as Code in Checks
**What:** Encode invariants in `checks` so unsafe drift fails before activation.
**When:** Every PR and local pre-switch.
**Example:**
```nix
checks.${system}.hetzner-eval = self.nixosConfigurations.hetzner-vps.config.system.build.toplevel;
checks.${system}.mac-eval = self.darwinConfigurations.macbook.system;
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Monolithic `configuration.nix`
**What:** One giant file for both hosts and concerns.
**Why bad:** Hidden coupling, hard reviews, poor reuse.
**Instead:** Split by responsibility (`shared/`, `darwin/`, `nixos/`, `hosts/`).

### Anti-Pattern 2: Mixed Bootstrap and Runtime Logic
**What:** Disk/provisioning logic entangled with regular service config.
**Why bad:** Risky day-2 deploys and accidental reprovisioning complexity.
**Instead:** Keep `disko` and installer concerns in explicit install modules/path.

### Anti-Pattern 3: Unpinned or Ad-Hoc Input Overrides
**What:** Frequent impure evals or local-only overrides for normal workflow.
**Why bad:** Non-reproducible outcomes across laptop/CI/server.
**Instead:** Pin in `flake.lock`; isolate experiments in dedicated branches.

## Suggested Build Order and Dependencies (for roadmap phases)

1. **Phase 1 - Repository Skeleton + Flake Control Plane**
   - Deliver: directory layout, `flake.nix`, pinned inputs, minimal host stubs
   - Depends on: none
   - Unblocks: everything

2. **Phase 2 - Shared Module Baseline**
   - Deliver: `modules/shared` for users, shell, common packages, base policy
   - Depends on: Phase 1
   - Unblocks: host composition without duplication

3. **Phase 3 - Host Composition (macOS + VPS)**
   - Deliver: `hosts/macbook` + `hosts/hetzner-vps` assembly and platform modules
   - Depends on: Phases 1-2
   - Unblocks: deterministic per-host builds

4. **Phase 4 - Validation Pipeline**
   - Deliver: `checks/` and CI wiring for `nix flake check` + host eval/build
   - Depends on: Phases 1-3
   - Unblocks: safe deployment gates

5. **Phase 5 - VPS Bootstrap Path**
   - Deliver: `disko` + `nixos-anywhere` runbook/config for first install/recovery
   - Depends on: Phase 3 (host definition), Phase 4 (validation)
   - Unblocks: reproducible fresh provisioning

6. **Phase 6 - Day-2 Deployment Path**
   - Deliver: `deploy-rs` topology, profile order, rollback-aware deploy commands
   - Depends on: Phases 3-4
   - Unblocks: repeatable remote operations

7. **Phase 7 - Hardening + Drift Controls**
   - Deliver: stricter checks, upgrade cadence policy, documentation and runbooks
   - Depends on: Phases 4-6
   - Unblocks: long-term maintainability

Dependency chain:

```text
P1 -> P2 -> P3 -> P4
P3 -> P5
P3 + P4 -> P6
P4 + P5 + P6 -> P7
```

## Scalability Considerations

| Concern | At 2 hosts (current) | At ~10 hosts | At 50+ hosts |
|---------|----------------------|--------------|--------------|
| Host sprawl | Manual host dirs are fine | Add host metadata map + generator helpers | Generate host definitions from inventory data |
| Eval cost | Negligible | Enforce `useGlobalPkgs`, reduce duplicate imports | Shard checks/jobs by host groups |
| Deploy coordination | Sequential manual deploys | Use deploy profile ordering and staged rollout | Add canary/ring strategy per role |
| Secret handling | Manual acceptable but risky | Introduce sops-nix/agenix boundary | Mandatory secret policy + rotation automation |

## Confidence Notes

- **HIGH:** Flake checks semantics and output contracts (`nix flake check` reference manual).
- **HIGH:** Home Manager integration modes and `useGlobalPkgs` guidance from Home Manager manual.
- **HIGH:** nix-darwin as the declarative macOS system layer.
- **MEDIUM:** Choice of deploy-rs as default day-2 deploy tool (strong ecosystem adoption and official README capabilities, but still community-maintained).
- **HIGH:** nixos-anywhere + disko pairing for unattended Hetzner provisioning.

## Sources

- Nix reference manual (`nix flake check`): https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-check
- Home Manager manual (integration modes, `useGlobalPkgs`): https://nix-community.github.io/home-manager/
- nix-darwin project and docs entrypoint: https://github.com/nix-darwin/nix-darwin
- deploy-rs README/API: https://github.com/serokell/deploy-rs
- nixos-anywhere README: https://github.com/nix-community/nixos-anywhere
- disko README: https://github.com/nix-community/disko
