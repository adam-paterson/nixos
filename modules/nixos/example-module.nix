# Example NixOS Module
# Demonstrates how to create a reusable NixOS module
#
# To use this module, add to your host's default.nix imports:
#   imports = [ ../../modules/nixos/example-module.nix ];

{ config, lib, pkgs, ... }:

with lib;

{
  # ============================================================================
  # Module Options
  # ============================================================================
  # Define options that users can set to configure this module
  
  options.myModule = {
    enable = mkEnableOption "My custom NixOS module";
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install when this module is enabled";
    };
    
    customMessage = mkOption {
      type = types.str;
      default = "Hello from custom module!";
      description = "A custom message to display";
    };
  };

  # ============================================================================
  # Module Configuration
  # ============================================================================
  # This configuration is applied when the module is enabled
  
  config = mkIf config.myModule.enable {
    # Add packages when module is enabled
    environment.systemPackages = with pkgs; [
      # Example packages for this module
      htop
      neofetch
      
      # Create a script that uses the custom message
      (writeShellScriptBin "my-module-script" ''
        echo "${config.myModule.customMessage}"
      '')
    ] ++ config.myModule.extraPackages;
    
    # Example: Enable a service
    # services.someService.enable = true;
    
    # Example: Create a systemd service
    # systemd.services.my-service = {
    #   description = "My Custom Service";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #     ExecStart = "${pkgs.bash}/bin/bash -c 'echo Running my service'";
    #   };
    # };
  };
}
