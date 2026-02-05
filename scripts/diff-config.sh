#!/usr/bin/env bash
# Show configuration changes between current and new config
# Usage: ./diff-config.sh [hostname]

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

HOSTNAME=${1:-$(hostname -s)}

# Detect OS and config type
if [[ "$OSTYPE" == "darwin"* ]]; then
  CONFIG_TYPE="darwin"
else
  CONFIG_TYPE="nixos"
fi

echo -e "${BLUE}📊 Configuration Diff for:${NC} ${GREEN}${HOSTNAME}${NC}"
echo ""

# Build new configuration
echo -e "${YELLOW}Building new configuration...${NC}"
NEW_CONFIG=$(nix build ".#${CONFIG_TYPE}Configurations.${HOSTNAME}.config.system.build.toplevel" --print-out-paths 2>/dev/null)

if [ -z "$NEW_CONFIG" ]; then
  echo -e "${RED}❌ Failed to build new configuration${NC}"
  exit 1
fi

# Get current system
if [ "$CONFIG_TYPE" = "darwin" ]; then
  CURRENT_SYSTEM="/run/current-system"
else
  CURRENT_SYSTEM="/run/current-system"
fi

if [ ! -e "$CURRENT_SYSTEM" ]; then
  echo -e "${YELLOW}⚠️  No current system found (fresh install?)${NC}"
  echo "New system will be: $NEW_CONFIG"
  exit 0
fi

echo -e "${YELLOW}Comparing configurations...${NC}"
echo ""

# Try to use nvd if available (nicer output)
if command -v nvd &>/dev/null; then
  nvd diff "$CURRENT_SYSTEM" "$NEW_CONFIG"
# Try nix-diff if available
elif command -v nix-diff &>/dev/null; then
  nix-diff "$CURRENT_SYSTEM" "$NEW_CONFIG"
else
  # Fallback to basic nix store diff
  echo -e "${BLUE}Packages changed:${NC}"
  nix store diff-closures "$CURRENT_SYSTEM" "$NEW_CONFIG" | head -50
  echo ""
  echo -e "${YELLOW}💡 Tip:${NC} Install 'nvd' for better diffs:"
  echo "  nix profile install nixpkgs#nvd"
fi

echo ""
echo -e "${GREEN}✅ Diff complete${NC}"
