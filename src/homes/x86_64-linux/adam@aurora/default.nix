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
