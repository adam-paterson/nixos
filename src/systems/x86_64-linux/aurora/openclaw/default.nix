{
  inputs,
  lib,
  config,
  ...
}: let
  openclawUser = "adam";
  homeDir = config.users.users.${openclawUser}.home;
  adamInstance = import ./instances/adam {homeDirectory = homeDir;};
  rachelInstance = import ./instances/rachel {homeDirectory = homeDir;};
in {
  home-manager.sharedModules = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  snowfallorg.users.${openclawUser}.home.config = {
    home.file = {
      ".openclaw-adam/workspace" = {
        source = ./config/documents;
        recursive = true;
      };

      ".openclaw-adam/workspace/agents" = {
        source = ./config/agents/adam;
        recursive = true;
      };

      ".openclaw-rachel/workspace" = {
        source = ./config/documents;
        recursive = true;
      };

      ".openclaw-rachel/workspace/agents" = {
        source = ./config/agents/rachel;
        recursive = true;
      };
    };

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
