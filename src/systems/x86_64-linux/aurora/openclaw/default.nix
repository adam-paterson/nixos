{
  inputs,
  lib,
  pkgs,
  ...
}: let
  adamInstance = import ./instances/adam;
  rachelInstance = import ./instances/rachel;
in {
  snowfallorg.users.adam.home.config = {
    imports = [
      inputs.openclaw.homeManagerModules.openclaw
    ];

    programs.openclaw = {
      package = inputs.openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw;
      installApp = false;
      launchd.enable = false;
      systemd.enable = true;

      documents = ./config/documents;

      bundledPlugins = {
        oracle.enable = true;
        sag.enable = true;
        gogcli.enable = true;
        goplaces.enable = true;
      };

      customPlugins = [
        {source = "github:openclaw/nix-steipete-tools";}
      ];

      config = {
        gateway.mode = "local";
      };

      instances = {
        adam = adamInstance;
        rachel = rachelInstance;
      };
    };

    home.stateVersion = lib.mkDefault "26.05";
  };
}
