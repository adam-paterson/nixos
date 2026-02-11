_: {
  # Keep this disabled if you install/manage Nix via Determinate Nix.
  nix.enable = false;

  system = {
    defaults = {
      # ╭────────────────────────────────────────────────────────╮
      # │ Login Window                                           │
      # ╰────────────────────────────────────────────────────────╯
      loginwindow = {
        GuestEnabled = false;
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Dock                                                   │
      # ╰────────────────────────────────────────────────────────╯
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = false;
        tilesize = 48;
        magnification = false;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps = [];
        persistent-others = [];
        showhidden = true;
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Finder                                                 │
      # ╰────────────────────────────────────────────────────────╯
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf"; # Search current folder
        FXEnableExtensionChangeWarning = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        NewWindowTarget = "Home";
        QuitMenuItem = true; # Allow quitting Finder
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Global Settings                                        │
      # ╰────────────────────────────────────────────────────────╯
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        AppleScrollerPagingBehavior = true;

        # Dark mode
        AppleInterfaceStyle = "Dark";

        # Keyboard
        ApplePressAndHoldEnabled = false; # Disable press-and-hold for keys
        InitialKeyRepeat = 15; # Faster key repeat
        KeyRepeat = 2; # Faster key repeat
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSWindowShouldDragOnGesture = true; # allows for cmd + ctrl and mouse drag to move windows instead of needing to click the title bar

        # Trackpad
        "com.apple.swipescrolldirection" = true; # Natural scrolling
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.trackpadCornerClickBehavior" = 1; # Enable right-click

        # Expand save/print dialogs by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Trackpad                                               │
      # ╰────────────────────────────────────────────────────────╯
      trackpad = {
        Clicking = true; # Tap to click
        TrackpadRightClick = true; # Two finger right click
        TrackpadThreeFingerDrag = true;
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Screenshots                                            │
      # ╰────────────────────────────────────────────────────────╯
      screencapture = {
        location = "~/Desktop/Screenshots";
        type = "png";
        disable-shadow = true;
      };

      # ╭────────────────────────────────────────────────────────╮
      # │ Software Update                                        │
      # ╰────────────────────────────────────────────────────────╯
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = false;
      };
    };

    # ╭────────────────────────────────────────────────────────╮
    # │ Keyboard                                               │
    # ╰────────────────────────────────────────────────────────╯
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = false;
    };
  };

  # ╭────────────────────────────────────────────────────────╮
  # │ Security                                               │
  # ╰────────────────────────────────────────────────────────╯
  security.pam.services.sudo_local.touchIdAuth = true;

  # ╭────────────────────────────────────────────────────────╮
  # │ User Defaults                                          │
  # ╰────────────────────────────────────────────────────────╯
  # Ensure screenshots directory exists
  system.activationScripts.postActivation.text = ''
    mkdir -p ~/Desktop/Screenshots
  '';
}
