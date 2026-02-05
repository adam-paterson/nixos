# Hetzner NixOS Configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  }

  # Networking
  networking = {
    hostname = "aurora";
    networkmanager.enable = true;
    firewall.enable = true;
  }

  # Time zone
  time.timeZone = "Europe/Berlin";

  # User account
  users.users.adam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
    ];
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    tmux
    git
    wget
    curl
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System state version
  system.stateVersion = "24.05";
}
