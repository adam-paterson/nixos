# Snowfall Configuration Guide

## Structure

```
src/
├── systems/              # System configurations
│   ├── aarch64-darwin/   # macOS systems
│   │   └── macbook/     # Your MacBook
│   └── x86_64-linux/     # Linux systems
│       └── hetzner/     # Hetzner server
└── homes/                # Home Manager configs
    ├── aarch64-darwin/   # macOS homes
    │   └── adam@macbook/
    └── x86_64-linux/     # Linux homes
        └── adam@hetzner/
```

## Commands

### Build MacBook (without activating)
```bash
nix build .#darwinConfigurations.macbook.system
```

### Switch MacBook (activate)
```bash
darwin-rebuild switch --flake .#macbook
# OR on first install:
nix run nix-darwin -- switch --flake .#macbook
```

### Build Hetzner (dry run)
```bash
nix build .#nixosConfigurations.hetzner.config.system.build.toplevel
```

### Switch Hetzner (activate)
```bash
# On the Hetzner server:
sudo nixos-rebuild switch --flake .#hetzner
```

### Build Home Manager for MacBook
```bash
home-manager switch --flake .#adam@macbook
```

### Build Home Manager for Hetzner
```bash
home-manager switch --flake .#adam@hetzner
```

## Important Notes

1. **Files must be in git**: Snowfall only discovers files that are tracked by git
2. **Naming convention**:
   - System configs: `systems/<arch>/<hostname>/default.nix`
   - Home configs: `homes/<arch>/<username>@<hostname>/default.nix`

3. **On Hetzner**: You'll need to generate hardware-configuration.nix:
   ```bash
   sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
   ```
   Then copy it to your repo's `src/systems/x86_64-linux/hetzner/hardware-configuration.nix`

## What We Accomplished

✅ flake.nix with snowfall-lib
✅ MacBook configuration (darwin)
✅ Hetzner configuration (nixos)
✅ Home Manager configurations for both
✅ Working build for MacBook

## Next Steps

1. **MacBook**: Test `darwin-rebuild switch --flake .#macbook`
2. **Hetzner**: Update `hardware-configuration.nix` with actual disk UUIDs from the server
3. **SSH Keys**: Add your SSH public key to hetzner config
4. **Email**: Update email addresses in home configs

## Snowfall Resources

- Main site: https://snowfall.org/
- Lib docs: https://snowfall.org/reference/lib/
