{...}: {
  imports = [
    ./programs/openclaw
  ];

  home = {
    username = "adam";
    homeDirectory = "/home/adam";
    stateVersion = "26.05";
  };

  cosmos = {
    home = {
      collections = {
        base.enable = true;
        dev.enable = true;
        cli.enable = true;
        ai.enable = true;
      };

      shells = {
        nushell.enable = true;

        listing = {
          eza.enable = false;
        };
      };

      planning = {
        beads.enable = true;
        gastown.enable = true;
      };

      security.onePasswordCLI = {
        environmentId = "unortf7rfmkyyjbmoufzjx2kr4";
      };

      cli = {
        codex.enable = true;
        openclaw.enable = true;
        btop.enable = true;
        delta.enable = true;
      };

      prompts = {
        ohMyPosh.enable = true;
        spaceship.enable = false;
      };

      editors.neovim.enableDAP = true;
    };
  };
}
