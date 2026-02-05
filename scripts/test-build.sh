#!/usr/bin/env bash
# Test NixOS/Darwin configurations without deploying
# Usage: ./scripts/test-build.sh [hostname]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get hostname argument
HOSTNAME=${1:-}

if [ -z "$HOSTNAME" ]; then
  error "Usage: $0 <hostname>"
  echo ""
  echo "Available configurations:"
  nix flake show 2>/dev/null | grep -E "(nixosConfigurations|darwinConfigurations)" -A 1
  exit 1
fi

# Detect configuration type
info "Checking configuration type for '$HOSTNAME'..."

if nix eval .#nixosConfigurations.$HOSTNAME.config.system.build.toplevel --json &>/dev/null; then
  CONFIG_TYPE="nixos"
  BUILD_TARGET=".#nixosConfigurations.$HOSTNAME.config.system.build.toplevel"
elif nix eval .#darwinConfigurations.$HOSTNAME.config.system.build.toplevel --json &>/dev/null; then
  CONFIG_TYPE="darwin"
  BUILD_TARGET=".#darwinConfigurations.$HOSTNAME.config.system.build.toplevel"
else
  error "Configuration '$HOSTNAME' not found in flake"
  exit 1
fi

info "Found $CONFIG_TYPE configuration for '$HOSTNAME'"

# Run flake check first
info "Running flake check..."
if ! nix flake check 2>&1 | grep -v "warning:"; then
  warn "Flake check completed with warnings (check output above)"
else
  info "Flake check passed"
fi

# Build the configuration
info "Building $CONFIG_TYPE configuration for '$HOSTNAME'..."
echo ""

if nix build "$BUILD_TARGET" --show-trace; then
  echo ""
  info "✓ Build successful!"
  info "Result: $(readlink -f result)"
  
  # Show some info about the build
  if [ "$CONFIG_TYPE" = "nixos" ]; then
    info "NixOS version: $(nix eval --raw $BUILD_TARGET.nixosVersion 2>/dev/null || echo "unknown")"
  else
    info "Darwin version: $(nix eval --raw $BUILD_TARGET.system.darwinLabel 2>/dev/null || echo "unknown")"
  fi
  
  echo ""
  info "To deploy this configuration:"
  if [ "$CONFIG_TYPE" = "nixos" ]; then
    echo "  sudo nixos-rebuild switch --flake .#$HOSTNAME"
    echo ""
    info "To test in a VM:"
    echo "  nix build .#nixosConfigurations.$HOSTNAME.config.system.build.vm"
    echo "  ./result/bin/run-$HOSTNAME-vm"
  else
    echo "  darwin-rebuild switch --flake .#$HOSTNAME"
  fi
  
  exit 0
else
  echo ""
  error "✗ Build failed!"
  error "Check the error messages above for details"
  echo ""
  info "Common issues:"
  echo "  - Syntax errors in .nix files"
  echo "  - Missing imports or undefined variables"
  echo "  - Overlays in wrong location (check host config, not home.nix)"
  echo ""
  info "For detailed trace, run:"
  echo "  nix build $BUILD_TARGET --show-trace"
  exit 1
fi
