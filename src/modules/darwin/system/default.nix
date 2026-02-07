{ ... }:
{
  # Keep this disabled if you install/manage Nix via Determinate Nix.
  nix.enable = false;

  system = {
    defaults = {
      loginwindow = {
        GuestEnabled = false;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        show-recents = false;
        tilesize = 48;
      };
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
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
