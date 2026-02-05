# Base Configuration - Shared by ALL hosts (NixOS and Darwin)
# See: .agents/skills/nixos-best-practices/rules/host-organization.md

{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # Nix Settings
  # ============================================================================
  
  nix = {
    # Enable flakes and nix-command
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize store automatically
      auto-optimise-store = true;
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  # ============================================================================
  # Package Configuration
  # ============================================================================
  
  # Allow unfree packages (like Discord, Slack, etc.)
  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # Environment
  # ============================================================================
  
  # Environment variables
  environment.variables = {
    EDITOR = "vim";
  };
}
