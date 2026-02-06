# MacBook System Configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../modules/base.nix  # Common packages for all systems
  ];

  # Host identification
  networking.hostName = "MACBOOK-002531";
  networking.computerName = "MACBOOK-002531";
  networking.localHostName = "MACBOOK-002531";

  # Nix settings - disable management since using Determinate Nix
  nix.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Primary user
  system.primaryUser = "adampaterson";

  # MacBook-specific packages (add only macOS-specific stuff here)
  environment.systemPackages = with pkgs; [
    # Add MacBook-only packages here
  ];

  # macOS system defaults
  system.defaults = {
    dock.autohide = true;
    finder.ShowStatusBar = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # State version
  system.stateVersion = 4;
}
