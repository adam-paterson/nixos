# Darwin Base Configuration - Shared by all macOS hosts
# See: .agents/skills/nixos-best-practices/rules/host-organization.md

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./base.nix  # Import universal base configuration
  ];

  # ============================================================================
  # System Packages
  # ============================================================================
  # See: .agents/skills/nixos-best-practices/rules/package-installation.md
  
  environment.systemPackages = with pkgs; [
    # Essential system utilities
    vim
    wget
    curl
    git
    
    # System monitoring
    htop
    btop
    
    # File management
    tree
    
    # Archive tools
    unzip
    zip
  ];

  # ============================================================================
  # macOS System Settings
  # ============================================================================
  
  system = {
    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;  # Remap Caps Lock to Escape
    };
    
    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };
      
      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        _FXShowPosixPathInTitle = true;
      };
      
      # NSGlobalDomain settings
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      
      # Trackpad settings
      trackpad = {
        Clicking = true;  # Enable tap to click
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  # ============================================================================
  # Services
  # ============================================================================
  
  # Enable Nix daemon
  services.nix-daemon.enable = true;

  # ============================================================================
  # Homebrew Integration (Optional)
  # ============================================================================
  # Uncomment to enable Homebrew integration
  # Note: You need to install Homebrew separately first
  
  # homebrew = {
  #   enable = true;
  #   onActivation = {
  #     autoUpdate = true;
  #     cleanup = "zap";
  #   };
  #   
  #   # Taps
  #   taps = [];
  #   
  #   # Formulae (CLI tools)
  #   brews = [];
  #   
  #   # Casks (GUI applications)
  #   casks = [
  #     # Examples:
  #     # "firefox"
  #     # "visual-studio-code"
  #   ];
  # };

  # ============================================================================
  # Security
  # ============================================================================
  
  security.pam.enableSudoTouchIdAuth = true;  # Enable Touch ID for sudo

  # ============================================================================
  # Users
  # ============================================================================
  
  # Define a user account
  # TODO: Replace 'username' with your actual macOS username
  users.users.username = {
    name = "username";
    home = "/Users/username";
  };
}
