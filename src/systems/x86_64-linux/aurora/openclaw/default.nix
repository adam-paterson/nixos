{
  inputs,
  lib,
  ...
}: let
  adamInstance = import ./instances/adam;
  rachelInstance = import ./instances/rachel;
in {
  home-manager.sharedModules = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  snowfallorg.users.adam.home.config = {
    programs.openclaw = {
      excludeTools = ["gogcli"];
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
