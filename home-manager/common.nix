# Common Home Manager Configuration
# Shared across all hosts and users

{ config, pkgs, ... }:

{
  imports = [
    # Import package groups
    ./packages/common.nix
  ];

  # ============================================================================
  # XDG Base Directory
  # ============================================================================
  
  xdg.enable = true;

  # ============================================================================
  # Session Variables
  # ============================================================================
  
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
