# Example Darwin Module
# Demonstrates how to create a reusable Darwin (macOS) module
#
# To use this module, add to your host's default.nix imports:
#   imports = [ ../../modules/darwin/example-module.nix ];

{ config, lib, pkgs, ... }:

with lib;

{
  # ============================================================================
  # Module Options
  # ============================================================================
  # Define options that users can set to configure this module
  
  options.myDarwinModule = {
    enable = mkEnableOption "My custom Darwin module";
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install when this module is enabled";
    };
    
    enableDarkMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable dark mode system-wide";
    };
  };

  # ============================================================================
  # Module Configuration
  # ============================================================================
  # This configuration is applied when the module is enabled
  
  config = mkIf config.myDarwinModule.enable {
    # Add packages when module is enabled
    environment.systemPackages = with pkgs; [
      # Example packages for this module
      htop
      neofetch
    ] ++ config.myDarwinModule.extraPackages;
    
    # Example: Set macOS system defaults
    system.defaults.NSGlobalDomain = mkIf config.myDarwinModule.enableDarkMode {
      AppleInterfaceStyle = "Dark";
    };
    
    # Example: Configure a service
    # launchd.user.agents.my-service = {
    #   serviceConfig = {
    #     ProgramArguments = [ "${pkgs.bash}/bin/bash" "-c" "echo 'Running my service'" ];
    #     RunAtLoad = true;
    #   };
    # };
  };
}
