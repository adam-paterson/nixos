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

        # OpenClaw is a host-local gaming utility not shared across hosts.
        openclaw.enable = true;
      };

      prompts = {
        ohMyPosh.enable = true;
        spaceship.enable = false;
      };

      editors.neovim.enableDAP = true;
    };
  };
}
