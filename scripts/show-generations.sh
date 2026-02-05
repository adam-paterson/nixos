#!/usr/bin/env bash
# Show system generations with details
# Works for both NixOS and Darwin

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect OS type
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="darwin"
else
  OS_TYPE="nixos"
fi

if [ "$OS_TYPE" = "darwin" ]; then
  # Darwin generations
  echo -e "${BLUE}📚 Darwin Generations:${NC}"
  echo ""
  
  PROFILE="/nix/var/nix/profiles/system"
  
  if [ ! -e "$PROFILE" ]; then
    echo "No system profile found"
    exit 0
  fi
  
  # List all generations
  nix-env --list-generations --profile "$PROFILE" | while read -r line; do
    if [[ $line == *"(current)"* ]]; then
      echo -e "${GREEN}→ $line${NC}"
    else
      echo "  $line"
    fi
  done
  
else
  # NixOS generations
  echo -e "${BLUE}📚 NixOS Generations:${NC}"
  echo ""
  
  PROFILE="/nix/var/nix/profiles/system"
  
  if [ ! -e "$PROFILE" ]; then
    echo "No system profile found"
    exit 0
  fi
  
  # List all generations with current highlighted
  sudo nix-env --list-generations --profile "$PROFILE" | while read -r line; do
    if [[ $line == *"(current)"* ]]; then
      echo -e "${GREEN}→ $line${NC}"
    else
      echo "  $line"
    fi
  done
fi

echo ""
echo -e "${YELLOW}💡 Tip:${NC} Rollback with: just rollback"
