# Example Darwin (macOS) Host Configuration
# See: .agents/skills/nixos-best-practices/rules/host-organization.md

{ inputs, config, pkgs, pkgs-stable, system, ... }:

{
  imports = [
    # Import shared Darwin base configuration
    ../darwin-base.nix
    
    # Import Home Manager Darwin module
    inputs.home-manager.darwinModules.home-manager
    
    # Import Agenix for secrets management
    inputs.agenix.darwinModules.default
    
    # Home Manager configuration inline
    # CRITICAL: This is where you configure Home Manager with useGlobalPkgs = true
    # See: .agents/skills/nixos-best-practices/rules/overlay-scope.md
    {
      home-manager = {
        # CRITICAL: useGlobalPkgs = true means overlays MUST be defined HERE,
        # not in home.nix! See overlay-scope.md for details.
        useGlobalPkgs = true;
        useUserPackages = true;
        
        # Import Home Manager configuration for this user
        # TODO: Replace 'username' with your actual macOS username
        users.username = import ./home.nix;
        
        # Pass extra arguments to Home Manager
        extraSpecialArgs = {
          inherit inputs pkgs-stable system;
        };
      };
      
      # ========================================================================
      # Overlays Configuration
      # ========================================================================
      # CRITICAL: With useGlobalPkgs = true, overlays MUST be defined HERE!
      # Overlays defined in home.nix will be IGNORED.
      # See: .agents/skills/nixos-best-practices/rules/overlay-scope.md
      
      nixpkgs.overlays = [
        # Add your overlays here
        # Example: inputs.some-flake.overlays.default
        # Example: (import ../overlays/example-overlay.nix)
      ];
    }
  ];

  # ============================================================================
  # Host-Specific Configuration
  # ============================================================================
  
  # Set hostname
  # TODO: Replace with your actual hostname
  networking.hostName = "example-darwin";
  networking.computerName = "example-darwin";
  networking.localHostName = "example-darwin";

  # ============================================================================
  # macOS System Settings (Host-Specific)
  # ============================================================================
  
  system.defaults = {
    # Additional dock settings
    dock = {
      # Pin dock to which side of screen
      # orientation = "left";  # "left", "bottom", "right"
      
      # Show indicator lights for open applications
      show-process-indicators = true;
      
      # Minimize windows using the scale effect
      mineffect = "scale";  # or "genie"
    };
    
    # Finder settings
    finder = {
      # Show status bar at bottom of Finder
      ShowStatusBar = true;
      
      # Show path bar at bottom of Finder
      ShowPathbar = true;
      
      # Default search scope: current folder
      FXDefaultSearchScope = "SCcf";
    };
    
    # Screenshots
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
    
    # Menu bar
    menuExtraClock = {
      Show24Hour = true;
    };
  };

  # ============================================================================
  # Additional Packages (Host-Specific)
  # ============================================================================
  
  # environment.systemPackages = with pkgs; [
  #   # Add host-specific system packages here
  # ];

  # ============================================================================
  # Homebrew Configuration (Host-Specific)
  # ============================================================================
  # Uncomment and customize if you want to use Homebrew
  
  # homebrew = {
  #   enable = true;
  #   
  #   # Install these GUI applications via Homebrew Cask
  #   casks = [
  #     # Examples:
  #     # "firefox"
  #     # "visual-studio-code"
  #     # "docker"
  #     # "slack"
  #     # "discord"
  #   ];
  #   
  #   # Install these CLI tools via Homebrew
  #   brews = [
  #     # Examples (if not available in nixpkgs):
  #   ];
  #   
  #   # Mac App Store apps
  #   masApps = {
  #     # Example: "1Password" = 1333542190;
  #   };
  # };

  # ============================================================================
  # Custom Modules
  # ============================================================================
  # Import custom modules as needed
  # Example: imports = [ ../../modules/darwin/example-module.nix ];

  # ============================================================================
  # State Version
  # ============================================================================
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
