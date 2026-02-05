# NixOS Base Configuration - Shared by all NixOS hosts
# See: .agents/skills/nixos-best-practices/rules/host-organization.md

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./base.nix  # Import universal base configuration
  ];

  # ============================================================================
  # Boot Configuration
  # ============================================================================
  
  boot = {
    # Use the latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Clean /tmp on boot
    tmp.cleanOnBoot = true;
  };

  # ============================================================================
  # Networking
  # ============================================================================
  
  networking = {
    # Enable NetworkManager for easy network configuration
    networkmanager.enable = true;
    
    # Firewall configuration
    firewall = {
      enable = true;
      # allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ];
    };
  };

  # ============================================================================
  # Localization
  # ============================================================================
  
  time.timeZone = "America/New_York";  # TODO: Change to your timezone
  
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ============================================================================
  # Users
  # ============================================================================
  
  # Define a user account
  # TODO: Replace 'username' with your actual username
  users.users.username = {
    isNormalUser = true;
    description = "User Name";  # TODO: Replace with your full name
    extraGroups = [ "networkmanager" "wheel" ];
    # initialPassword = "changeme";  # Uncomment for first boot
  };

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
    
    # Network tools
    inetutils
    
    # File management
    tree
    
    # Archive tools
    unzip
    zip
  ];

  # ============================================================================
  # Services
  # ============================================================================
  
  # Enable OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Enable CUPS for printing (optional - uncomment if needed)
  # services.printing.enable = true;

  # ============================================================================
  # Security
  # ============================================================================
  
  # Enable sudo
  security.sudo.enable = true;
  
  # Sudo timeout
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';
}
