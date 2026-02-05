# Home Manager Configuration for example-darwin
# See: .agents/skills/nixos-best-practices/rules/package-installation.md

{ config, pkgs, inputs, pkgs-stable, ... }:

{
  imports = [
    # Import shared Home Manager configurations
    ../../home-manager/common.nix
    ../../home-manager/programs/git.nix
    ../../home-manager/programs/shell.nix
  ];

  # ============================================================================
  # Basic Home Manager Configuration
  # ============================================================================
  
  # TODO: Replace 'username' with your actual macOS username
  home.username = "username";
  home.homeDirectory = "/Users/username";

  # This value determines the Home Manager release compatibility
  # Don't change this unless you know what you're doing!
  home.stateVersion = "24.05";

  # ============================================================================
  # User Packages (Host-Specific)
  # ============================================================================
  # See: .agents/skills/nixos-best-practices/rules/package-installation.md
  
  home.packages = with pkgs; [
    # Add host-specific packages here
    # Examples:
    # firefox
    # vscode
    # discord
  ];
  
  # You can also use packages from stable channel
  # home.packages = with pkgs-stable; [
  #   some-stable-package
  # ];

  # ============================================================================
  # CRITICAL: Overlay Configuration
  # ============================================================================
  # DO NOT define overlays here when useGlobalPkgs = true!
  # Overlays MUST be defined in the host's default.nix file.
  # See: .agents/skills/nixos-best-practices/rules/overlay-scope.md
  #
  # ❌ WRONG:
  # nixpkgs.overlays = [ ... ];  # This will be IGNORED!
  #
  # ✅ CORRECT:
  # Define overlays in hosts/example-darwin/default.nix instead

  # ============================================================================
  # Git Configuration (Host-Specific Overrides)
  # ============================================================================
  
  # Shared git config is in home-manager/programs/git.nix
  # Add host-specific overrides here if needed
  # programs.git = {
  #   extraConfig = {
  #     # Host-specific git settings
  #   };
  # };

  # ============================================================================
  # macOS-Specific Settings
  # ============================================================================
  
  # macOS-specific home directory customizations
  # home.file.".hushlogin".text = "";  # Silence login message

  # ============================================================================
  # Programs
  # ============================================================================
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
