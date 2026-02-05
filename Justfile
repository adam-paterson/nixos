# NixOS & Darwin Justfile
# Easy commands for common Nix operations
# 
# Quick Start:
#   just --list          List all available commands
#   just help            Show detailed help with examples
#   just build           Test build configuration
#   just switch          Build and activate configuration

# Variables
_hostname := `hostname -s`
_is_darwin := if os() == "macos" { "true" } else { "false" }
_is_nixos := if os() == "linux" { "true" } else { "false" }

# Default recipe - show help
default:
    @just --list

# Show detailed help with examples
help:
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo "  NixOS & Darwin Configuration - Task Runner"
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "Current System: {{if _is_darwin == "true" { "Darwin (macOS)" } else { "NixOS (Linux)" }}}"
    @echo "Detected Hostname: {{_hostname}}"
    @echo ""
    @echo "━━━ Common Commands ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "  just build [hostname]    Test build without activating"
    @echo "  just switch [hostname]   Build and activate configuration"
    @echo "  just update [input]      Update dependencies"
    @echo "  just check               Validate configuration"
    @echo ""
    @echo "━━━ Maintenance ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "  just clean               Remove garbage (keep recent)"
    @echo "  just clean-all           Remove all old generations"
    @echo "  just generations         Show system generations"
    @echo "  just rollback            Rollback to previous generation"
    @echo ""
    @echo "━━━ Development ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "  just fmt                 Format all Nix files"
    @echo "  just search <query>      Search for packages"
    @echo "  just show                Show flake information"
    @echo "  just diff                Show config changes"
    @echo ""
    @echo "━━━ Secrets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "  just secret <name>       Edit an agenix secret"
    @echo "  just secret-list         List all secrets"
    @echo ""
    @echo "━━━ Examples ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "  # Auto-detect hostname and build"
    @echo "  just build"
    @echo ""
    @echo "  # Specify hostname explicitly"
    @echo "  just build example-darwin"
    @echo ""
    @echo "  # Update all dependencies and rebuild"
    @echo "  just update && just check && just switch"
    @echo ""
    @echo "  # Search for a package"
    @echo "  just search nodejs"
    @echo ""
    @echo "  # Format code before committing"
    @echo "  just fmt"
    @echo ""
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "For more information, see: README.md"
    @echo ""

# ============================================================================
# Build & Deploy
# ============================================================================

# Build configuration without activating (test build)
build hostname=_hostname:
    @echo "🔨 Building configuration for: {{hostname}}"
    @./scripts/detect-config.sh {{hostname}} build

# Build and activate configuration
switch hostname=_hostname:
    @echo "🚀 Deploying configuration for: {{hostname}}"
    @./scripts/detect-config.sh {{hostname}} switch

# Test configuration (activates but doesn't persist on reboot)
test hostname=_hostname:
    @echo "🧪 Testing configuration for: {{hostname}}"
    @./scripts/detect-config.sh {{hostname}} test

# ============================================================================
# Updates & Maintenance
# ============================================================================

# Update flake inputs (all or specific input)
update input="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{input}}" ]; then
        echo "⬆️  Updating all flake inputs..."
        nix flake update
    else
        echo "⬆️  Updating {{input}}..."
        nix flake lock --update-input {{input}}
    fi
    echo "✅ Update complete!"
    echo ""
    echo "Changes made:"
    git diff flake.lock | head -50

# Check flake configuration for errors
check:
    @echo "🔍 Checking flake configuration..."
    @nix flake check

# Show flake metadata and inputs
show:
    @echo "📋 Flake Information:"
    @echo ""
    @nix flake metadata
    @echo ""
    @echo "📦 Available Configurations:"
    @nix flake show

# ============================================================================
# Garbage Collection
# ============================================================================

# Clean up old generations and garbage (keep last 7 days)
clean:
    @echo "🧹 Cleaning up old generations (keeping last 7 days)..."
    {{if _is_darwin == "true" { "nix-collect-garbage --delete-older-than 7d" } else { "sudo nix-collect-garbage --delete-older-than 7d" }}}
    @echo "✅ Cleanup complete!"

# Delete ALL old generations and garbage (CAREFUL!)
clean-all:
    @echo "⚠️  WARNING: This will delete ALL old generations!"
    @read -p "Are you sure? (yes/no): " confirm; \
    if [ "$$confirm" = "yes" ]; then \
        echo "🧹 Removing all old generations..."; \
        {{if _is_darwin == "true" { "nix-collect-garbage -d" } else { "sudo nix-collect-garbage -d" }}}; \
        echo "✅ All old generations removed!"; \
    else \
        echo "❌ Cancelled"; \
    fi

# List system generations
generations:
    @echo "📚 System Generations:"
    @echo ""
    @./scripts/show-generations.sh

# Rollback to previous generation
rollback:
    @echo "⏮️  Rolling back to previous generation..."
    {{if _is_darwin == "true" { "darwin-rebuild --rollback" } else { "sudo nixos-rebuild --rollback switch" }}}
    @echo "✅ Rollback complete!"

# ============================================================================
# Development
# ============================================================================

# Format all Nix files
fmt:
    @echo "✨ Formatting Nix files..."
    @nix fmt
    @echo "✅ Formatting complete!"

# Search for packages in nixpkgs
search query:
    @echo "🔍 Searching nixpkgs for: {{query}}"
    @nix search nixpkgs {{query}}

# Show what changed in the configuration
diff hostname=_hostname:
    @echo "📊 Configuration changes for: {{hostname}}"
    @./scripts/diff-config.sh {{hostname}}

# ============================================================================
# Secrets Management
# ============================================================================

# Edit an agenix secret
secret name:
    @echo "🔐 Editing secret: {{name}}"
    @if command -v agenix >/dev/null 2>&1; then \
        agenix -e secrets/{{name}}.age; \
    else \
        echo "❌ agenix not found. Install with: nix profile install nixpkgs#agenix"; \
        exit 1; \
    fi

# List all defined secrets
secret-list:
    @echo "🔐 Defined Secrets:"
    @echo ""
    @grep -E '^\s*".*\.age"' secrets/secrets.nix | sed 's/.*"\(.*\)".*/  - \1/' || echo "  No secrets defined"

# ============================================================================
# Advanced
# ============================================================================

# Build a VM for testing (NixOS only)
vm hostname=_hostname:
    @echo "🖥️  Building VM for: {{hostname}}"
    @if [ "{{_is_nixos}}" = "true" ]; then \
        nix build .#nixosConfigurations.{{hostname}}.config.system.build.vm; \
        echo "✅ VM built! Run with: ./result/bin/run-{{hostname}}-vm"; \
    else \
        echo "❌ VM building only works on NixOS"; \
        exit 1; \
    fi

# Show size of system closure
size hostname=_hostname:
    @echo "📊 System closure size for: {{hostname}}"
    @./scripts/detect-config.sh {{hostname}} size

# Rebuild from a clean slate (useful for debugging)
rebuild-clean hostname=_hostname:
    @echo "🔄 Clean rebuild for: {{hostname}}"
    @just clean
    @just build {{hostname}}
    @echo "✅ Clean rebuild complete!"

# ============================================================================
# Git Helpers
# ============================================================================

# Show git status of config
status:
    @git status

# Commit changes with a message
commit message:
    @git add .
    @git commit -m "{{message}}"

# Push changes to remote
push:
    @git push

# Full workflow: format, check, commit, push
publish message:
    @just fmt
    @just check
    @git add .
    @git commit -m "{{message}}"
    @git push
    @echo "✅ Published changes!"
