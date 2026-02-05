#!/usr/bin/env bash
# Detect configuration type and hostname, then execute command
# Usage: ./detect-config.sh [hostname] [command]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get arguments
HOSTNAME=${1:-$(hostname -s)}
COMMAND=${2:-"build"}

# Detect OS type
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="darwin"
  REBUILD_CMD="darwin-rebuild"
else
  OS_TYPE="nixos"
  REBUILD_CMD="nixos-rebuild"
fi

# Function to check if configuration exists
config_exists() {
  local config_type=$1
  local hostname=$2
  
  if nix eval ".#${config_type}Configurations.${hostname}.config.system.build.toplevel" --json &>/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Try to find the configuration
if config_exists "$OS_TYPE" "$HOSTNAME"; then
  CONFIG_TYPE="$OS_TYPE"
elif config_exists "darwin" "$HOSTNAME"; then
  CONFIG_TYPE="darwin"
elif config_exists "nixos" "$HOSTNAME"; then
  CONFIG_TYPE="nixos"
else
  echo -e "${RED}❌ Error:${NC} Configuration '${HOSTNAME}' not found in flake"
  echo ""
  echo "Available configurations:"
  nix flake show 2>/dev/null | grep -E "(nixosConfigurations|darwinConfigurations)" -A 1 || echo "  None found"
  exit 1
fi

# Set the appropriate rebuild command
if [ "$CONFIG_TYPE" = "darwin" ]; then
  REBUILD_CMD="darwin-rebuild"
  USE_SUDO=""
else
  REBUILD_CMD="nixos-rebuild"
  USE_SUDO="sudo "
fi

# Execute the requested command
case "$COMMAND" in
  build)
    echo -e "${BLUE}🔨 Building${NC} ${CONFIG_TYPE} configuration for: ${GREEN}${HOSTNAME}${NC}"
    nix build ".#${CONFIG_TYPE}Configurations.${HOSTNAME}.config.system.build.toplevel" --show-trace
    echo -e "${GREEN}✅ Build successful!${NC}"
    ;;
    
  switch)
    echo -e "${BLUE}🚀 Deploying${NC} ${CONFIG_TYPE} configuration for: ${GREEN}${HOSTNAME}${NC}"
    ${USE_SUDO}${REBUILD_CMD} switch --flake ".#${HOSTNAME}"
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    ;;
    
  test)
    echo -e "${BLUE}🧪 Testing${NC} ${CONFIG_TYPE} configuration for: ${GREEN}${HOSTNAME}${NC}"
    ${USE_SUDO}${REBUILD_CMD} test --flake ".#${HOSTNAME}"
    echo -e "${GREEN}✅ Test successful!${NC}"
    ;;
    
  size)
    echo -e "${BLUE}📊 Calculating size${NC} for: ${GREEN}${HOSTNAME}${NC}"
    nix path-info -Sh ".#${CONFIG_TYPE}Configurations.${HOSTNAME}.config.system.build.toplevel"
    ;;
    
  *)
    echo -e "${RED}❌ Error:${NC} Unknown command: ${COMMAND}"
    echo "Available commands: build, switch, test, size"
    exit 1
    ;;
esac
