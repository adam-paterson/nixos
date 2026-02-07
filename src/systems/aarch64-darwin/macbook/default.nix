{ lib, ... }:
{
  networking.hostName = lib.mkForce "MACBOOK-002531";
  networking.computerName = lib.mkForce "MACBOOK-002531";
  networking.localHostName = lib.mkForce "MACBOOK-002531";

  # Set to your local macOS username.
  system.primaryUser = "adampaterson";

  # Keep this disabled if you install/manage Nix via Determinate Nix.
  nix.enable = false;

  system.defaults = {
    dock.autohide = true;
    finder.ShowStatusBar = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 4;
}
