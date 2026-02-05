# NixOS & Darwin Configuration

A comprehensive, well-structured NixOS and nix-darwin flake configuration repository following best practices. This repository supports both Linux (NixOS) and macOS (Darwin) hosts with integrated Home Manager.

## Table of Contents

- [Features](#features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Quick Commands](#quick-commands-task-runners)
- [Adding a New Host](#adding-a-new-host)
- [Using Overlays](#using-overlays-critical)
- [Secrets Management](#secrets-management)
- [Common Tasks](#common-tasks)
- [Task Runner Reference](#task-runner-reference)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Features

- **Multi-OS Support**: Configure both NixOS (Linux) and Darwin (macOS) systems
- **Home Manager Integration**: User-level configuration with `useGlobalPkgs = true`
- **Shared Base Configurations**: Reduce duplication across hosts
- **Stable Channel Support**: Access both unstable and stable nixpkgs
- **Custom Overlays**: Examples for adding custom packages
- **Reusable Modules**: Modular configuration for better organization
- **Secrets Management**: Integrated agenix for encrypted secrets
- **Best Practices**: Follows recommendations from `.agents/skills/nixos-best-practices/`

## Repository Structure

```
nixos-config/
├── flake.nix                      # Main flake configuration
├── flake.lock                     # Locked dependency versions
├── .gitignore                     # Git ignore rules
│
├── hosts/                         # Host configurations
│   ├── base.nix                   # Universal settings (NixOS + Darwin)
│   ├── nixos-base.nix             # Shared NixOS configuration
│   ├── darwin-base.nix            # Shared Darwin configuration
│   ├── example-nixos/             # Example NixOS host
│   │   ├── default.nix            # Host configuration
│   │   ├── hardware-configuration.nix  # Hardware config
│   │   └── home.nix               # Home Manager config
│   └── example-darwin/            # Example Darwin host
│       ├── default.nix            # Host configuration
│       └── home.nix               # Home Manager config
│
├── home-manager/                  # Shared Home Manager configs
│   ├── common.nix                 # Common settings
│   ├── programs/                  # Program configurations
│   │   ├── git.nix
│   │   └── shell.nix
│   └── packages/                  # Package groups
│       ├── common.nix
│       └── development.nix
│
├── modules/                       # Reusable modules
│   ├── nixos/
│   │   └── example-module.nix
│   └── darwin/
│       └── example-module.nix
│
├── overlays/                      # Custom overlays
│   └── example-overlay.nix
│
└── secrets/                       # Encrypted secrets (agenix)
    ├── secrets.nix                # Secret definitions
    └── .gitignore
```

## Prerequisites

### For NixOS

- NixOS installed with flakes enabled
- Git installed

### For macOS (Darwin)

- Nix package manager installed
- Git installed
- Enable flakes in your Nix configuration:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Getting Started

### 1. Clone this repository

```bash
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config
```

## Quick Commands (Task Runners)

This repository includes **Just** and **Nx** task runners to make common operations easy. No need to remember complex Nix commands!

### Using Just (Recommended for Beginners)

[Just](https://github.com/casey/just) is a simple command runner. Install it first:

```bash
# On macOS with Homebrew
brew install just

# Or with Nix
nix profile install nixpkgs#just
```

**Common commands:**

```bash
# Show all available commands
just

# Show detailed help with examples
just help

# Build configuration (auto-detects your hostname)
just build

# Build and activate configuration
just switch

# Update all dependencies
just update

# Check configuration for errors
just check

# Format Nix files
just fmt

# Search for packages
just search nodejs

# Clean up old generations
just clean

# Show system generations
just generations

# Edit a secret
just secret api-key
```

**Auto-detection:** Commands automatically detect your hostname and OS type (Darwin/NixOS). You can override:

```bash
just build example-darwin   # Build specific host
just switch my-hostname     # Switch specific host
```

### Using Nx (Advanced, Optional)

[Nx](https://nx.dev) provides task caching and advanced features. Requires Node.js:

```bash
# Install nx globally
npm install -g nx

# Or run with npx
npx nx <command>
```

**Common commands:**

```bash
# Show all available tasks
nx show projects

# Build configuration
nx run build

# Build with caching (faster rebuilds)
nx run build --skip-nx-cache=false

# Check configuration
nx run check

# Update dependencies
nx run update

# Format code
nx run format

# Show what tasks are available
nx show project nixos-darwin-config
```

**Benefits of Nx:**
- Task result caching (faster rebuilds)
- Build multiple hosts in parallel
- See what changed with `nx affected`

### 2. Customize for your system

Before building, customize the configuration:

1. **Update usernames**: Replace `username` with your actual username in:
   - `hosts/nixos-base.nix` (line 61)
   - `hosts/darwin-base.nix` (line 113)
   - `hosts/example-nixos/home.nix` (line 18-19)
   - `hosts/example-darwin/home.nix` (line 18-19)

2. **Update git config**: Edit `home-manager/programs/git.nix`:
   - Set your name and email in `settings.user` section (lines 10-11)

3. **Update timezone**: Edit `hosts/nixos-base.nix`:
   - Set your timezone (line 49)

### 3. Initialize the flake

```bash
# Update flake inputs
nix flake update

# Check flake structure
nix flake check
```

### 4. Build and switch

#### For NixOS:

```bash
# Test build without activating
sudo nixos-rebuild build --flake .#example-nixos

# Switch to new configuration
sudo nixos-rebuild switch --flake .#example-nixos
```

#### For Darwin (macOS):

```bash
# Test build without activating
darwin-rebuild build --flake .#example-darwin

# Switch to new configuration
darwin-rebuild switch --flake .#example-darwin
```

## Adding a New Host

### NixOS Host

1. **Generate hardware configuration**:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/YOUR-HOSTNAME/hardware-configuration.nix
   ```

2. **Copy example host**:
   ```bash
   cp -r hosts/example-nixos hosts/YOUR-HOSTNAME
   ```

3. **Update configuration**:
   - Edit `hosts/YOUR-HOSTNAME/default.nix`:
     - Change `networking.hostName` to `YOUR-HOSTNAME`
     - Update username references
   - Edit `hosts/YOUR-HOSTNAME/home.nix`:
     - Update username and home directory

4. **Add to flake.nix**:
   ```nix
   nixosConfigurations.YOUR-HOSTNAME = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = {
       inherit inputs;
       system = "x86_64-linux";
       pkgs-stable = mkPkgsStable "x86_64-linux";
     };
     modules = [ ./hosts/YOUR-HOSTNAME ];
   };
   ```

5. **Build**:
   ```bash
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME
   ```

### Darwin (macOS) Host

1. **Copy example host**:
   ```bash
   cp -r hosts/example-darwin hosts/YOUR-HOSTNAME
   ```

2. **Update configuration**:
   - Edit `hosts/YOUR-HOSTNAME/default.nix`:
     - Change hostnames to `YOUR-HOSTNAME`
     - Update username references
     - Update system architecture if needed (Intel vs Apple Silicon)
   - Edit `hosts/YOUR-HOSTNAME/home.nix`:
     - Update username and home directory

3. **Add to flake.nix**:
   ```nix
   darwinConfigurations.YOUR-HOSTNAME = darwin.lib.darwinSystem {
     system = "aarch64-darwin";  # or "x86_64-darwin" for Intel
     specialArgs = {
       inherit inputs;
       system = "aarch64-darwin";
       pkgs-stable = mkPkgsStable "aarch64-darwin";
     };
     modules = [ ./hosts/YOUR-HOSTNAME ];
   };
   ```

4. **Build**:
   ```bash
   darwin-rebuild switch --flake .#YOUR-HOSTNAME
   ```

## Using Overlays (CRITICAL)

This repository uses `useGlobalPkgs = true` for Home Manager, which affects where overlays must be defined.

### ⚠️ Important: Overlay Scope

**With `useGlobalPkgs = true`, overlays MUST be defined in the host configuration (default.nix), NOT in home.nix!**

See: `.agents/skills/nixos-best-practices/rules/overlay-scope.md` for detailed explanation.

### ✅ CORRECT: Define overlay in host config

```nix
# hosts/YOUR-HOSTNAME/default.nix
{
  imports = [
    # ... other imports ...
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.username = import ./home.nix;
      home-manager.extraSpecialArgs = { inherit inputs pkgs-stable system; };
      
      # ✅ Define overlays HERE
      nixpkgs.overlays = [
        (import ../../overlays/example-overlay.nix)
        inputs.some-flake.overlays.default
      ];
    }
  ];
}
```

### ❌ WRONG: Define overlay in home.nix

```nix
# hosts/YOUR-HOSTNAME/home.nix
{
  # ❌ This will be IGNORED when useGlobalPkgs = true!
  nixpkgs.overlays = [ ... ];
}
```

### Creating a Custom Overlay

1. Create overlay file in `overlays/`:
   ```nix
   # overlays/my-overlay.nix
   final: prev: {
     my-package = prev.writeShellScriptBin "my-package" ''
       echo "Hello from my custom package!"
     '';
   }
   ```

2. Add to host configuration:
   ```nix
   nixpkgs.overlays = [
     (import ../../overlays/my-overlay.nix)
   ];
   ```

3. Use in packages:
   ```nix
   home.packages = with pkgs; [
     my-package  # Now available!
   ];
   ```

## Secrets Management

This repository uses [agenix](https://github.com/ryantm/agenix) for encrypted secrets.

### Initial Setup

1. **Generate SSH keys** (if you haven't already):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **Get your public keys**:
   ```bash
   # User key
   cat ~/.ssh/id_ed25519.pub
   
   # Host key (on NixOS)
   sudo cat /etc/ssh/ssh_host_ed25519_key.pub
   
   # Host key (on Darwin)
   sudo cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

3. **Update `secrets/secrets.nix`**:
   - Replace example public keys with your actual keys

### Creating Secrets

1. **Install agenix**:
   ```bash
   nix profile install nixpkgs#agenix
   ```

2. **Create/edit a secret**:
   ```bash
   agenix -e secrets/my-secret.age
   ```

3. **Add secret to `secrets/secrets.nix`**:
   ```nix
   "my-secret.age".publicKeys = users ++ systems;
   ```

4. **Use secret in configuration**:
   ```nix
   age.secrets.my-secret = {
     file = ../secrets/my-secret.age;
     owner = "username";
     group = "users";
   };
   
   # Access with: config.age.secrets.my-secret.path
   ```

## Common Tasks

This section shows traditional Nix commands alongside convenient Just shortcuts.

### Update All Packages

**With Just:**
```bash
just update
```

**Traditional:**
```bash
# Update flake inputs
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#hostname  # NixOS
darwin-rebuild switch --flake .#hostname      # Darwin
```

### Update Specific Input

**With Just:**
```bash
just update-input nixpkgs
```

**Traditional:**
```bash
nix flake lock --update-input nixpkgs
```

### Check for Errors

**With Just:**
```bash
just check
```

**Traditional:**
```bash
nix flake check
```

### Format Code

**With Just:**
```bash
just fmt
```

**Traditional:**
```bash
nix fmt
```

### Search for Packages

**With Just:**
```bash
just search nodejs
```

**Traditional:**
```bash
nix search nixpkgs nodejs
```

### View Generations

**With Just:**
```bash
just generations
```

**Traditional (NixOS):**
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

**Traditional (Darwin):**
```bash
darwin-rebuild --list-generations
```

### Rollback to Previous Generation

**With Just:**
```bash
just rollback
```

**Traditional (NixOS):**
```bash
sudo nixos-rebuild switch --rollback
```

**Traditional (Darwin):**
```bash
darwin-rebuild --rollback
```

### Clean Up Old Generations

**With Just:**
```bash
just clean        # Delete generations older than 30 days
just clean 7      # Keep only last 7 days
```

**Traditional:**
```bash
# Delete old generations
sudo nix-collect-garbage -d

# Or keep last N days
sudo nix-collect-garbage --delete-older-than 30d
```

### View Configuration Diff

**With Just:**
```bash
just diff
```

**Traditional:**
```bash
# Use nvd or nix-diff (must be installed separately)
nvd diff /run/current-system result
```

## Task Runner Reference

### Just Commands

Run `just` or `just --list` to see all available commands:

| Command | Description |
|---------|-------------|
| `just` | Show available commands |
| `just help` | Show detailed help with examples |
| `just build [HOST]` | Build configuration without activating |
| `just switch [HOST]` | Build and activate configuration |
| `just check` | Check flake for errors |
| `just update` | Update all flake inputs |
| `just update-input INPUT` | Update specific input (e.g., nixpkgs) |
| `just fmt` | Format Nix files with nixpkgs-fmt |
| `just search QUERY` | Search for packages |
| `just clean [DAYS]` | Remove old generations (default: 30 days) |
| `just generations` | Show system generations |
| `just rollback` | Rollback to previous generation |
| `just diff` | Show configuration changes |
| `just gc` | Garbage collect nix store |
| `just optimize` | Optimize nix store |
| `just repair` | Repair nix store |
| `just show-config` | Show current system configuration |
| `just show-inputs` | Show flake inputs and versions |
| `just secret NAME` | Edit secret with agenix |

**Git helpers:**

| Command | Description |
|---------|-------------|
| `just status` | Show git status |
| `just commit MSG` | Commit changes with message |
| `just push` | Push to remote |
| `just publish MSG` | Add all, commit, and push |

**Host override examples:**
```bash
just build example-darwin        # Build specific host
just switch my-nixos-machine     # Switch specific host
```

### Nx Commands

Run `nx show project nixos-darwin-config` to see all available tasks:

| Command | Description |
|---------|-------------|
| `nx run build` | Build configuration |
| `nx run switch` | Build and activate |
| `nx run check` | Check for errors |
| `nx run update` | Update dependencies |
| `nx run format` | Format code |
| `nx run clean` | Clean old generations |
| `nx run test` | Test build without activating |
| `nx run gc` | Garbage collect |

**With caching:**
```bash
nx run build --skip-nx-cache=false
```

**View task graph:**
```bash
nx graph
```

### Helper Scripts

The `scripts/` directory contains useful utilities:

- `scripts/detect-config.sh` - Auto-detect hostname and build/switch
- `scripts/show-generations.sh` - Display system generations
- `scripts/diff-config.sh` - Show configuration differences
- `scripts/test-build.sh` - Test build without activation

These scripts are used internally by Just commands but can be run directly:

```bash
./scripts/detect-config.sh build
./scripts/show-generations.sh
./scripts/diff-config.sh
```

## Troubleshooting

### Task Runners

#### "command not found: just"

**Solution**: Install Just first:
```bash
# On macOS with Homebrew
brew install just

# Or with Nix
nix profile install nixpkgs#just
```

#### "command not found: nx"

**Solution**: Install Nx globally:
```bash
npm install -g nx

# Or run without installing
npx nx <command>
```

#### "Configuration 'HOSTNAME' not found in flake"

**Solution**: Your hostname doesn't match any configuration. Either:

1. Create a new host configuration matching your hostname:
   ```bash
   hostname -s  # Check your hostname
   ```

2. Or explicitly specify a host:
   ```bash
   just build example-darwin
   ```

3. Or create a local override (`.justfile.local`):
   ```bash
   # .justfile.local
   export NIXOS_CONFIG := "example-darwin"
   ```

### NixOS/Nix Issues

### "undefined variable 'inputs'"

**Solution**: Ensure `specialArgs = { inherit inputs; }` is in your `flake.nix`.

See: `.agents/skills/nixos-best-practices/rules/common-mistakes.md`

### "attribute 'package-name' not found"

**Solution**: Check if overlay is defined in correct location (host config, not home.nix).

See: `.agents/skills/nixos-best-practices/rules/overlay-scope.md`

### Configuration changes don't apply

1. Verify rebuild succeeded without errors
2. Check you're editing the correct file
3. For overlays, ensure they're in host config when using `useGlobalPkgs = true`

See: `.agents/skills/nixos-best-practices/rules/troubleshooting.md`

### Build fails with syntax error

```bash
# Check flake syntax
nix flake check

# Or with Just
just check

# Build with trace for detailed errors
sudo nixos-rebuild build --flake .#hostname --show-trace
```

## Best Practices

This repository follows best practices documented in `.agents/skills/nixos-best-practices/`:

1. **Overlay Scope** (`.agents/skills/nixos-best-practices/rules/overlay-scope.md`)
   - With `useGlobalPkgs = true`, define overlays in host config, not home.nix

2. **Flakes Structure** (`.agents/skills/nixos-best-practices/rules/flakes-structure.md`)
   - Use `@inputs` pattern
   - Pass inputs via `specialArgs`
   - Use `inputs.nixpkgs.follows` to avoid duplicate nixpkgs

3. **Host Organization** (`.agents/skills/nixos-best-practices/rules/host-organization.md`)
   - Shared config in base files
   - Host-specific config in host directories
   - Never edit `hardware-configuration.nix` manually

4. **Package Installation** (`.agents/skills/nixos-best-practices/rules/package-installation.md`)
   - System packages in `environment.systemPackages`
   - User packages in `home.packages`
   - Choose appropriate location based on scope

5. **Common Mistakes** (`.agents/skills/nixos-best-practices/rules/common-mistakes.md`)
   - Don't forget `specialArgs`
   - Don't edit hardware-configuration.nix
   - Don't duplicate package declarations
   - Use `.follows` for inputs

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Agenix Documentation](https://github.com/ryantm/agenix)
- [NixOS Best Practices](.agents/skills/nixos-best-practices/)

## Contributing

Feel free to customize this configuration for your needs. If you find improvements, consider documenting them for future reference.

## License

This configuration is provided as-is for personal use. Customize as needed for your environment.
