# MacBook Configuration
{ config, lib, pkgs, ... }:

{
  networking.hostName = "MACBOOK-002531";
  networking.computerName = "MACBOOK-002531";
  networking.localHostName = "MACBOOK-002531";

  # Nix settings - disable management since using Determinate Nix
  nix.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
  ];

  # Primary user (must match actual username)
  system.primaryUser = "adampaterson";

  # macOS system defaults
  system.defaults = {
    dock.autohide = true;
    finder.ShowStatusBar = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # State version
  system.stateVersion = "24.05";
}
