_: {
  home = {
    username = "adampaterson";
    homeDirectory = "/Users/adampaterson";
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
      };

      cli = {
        codex.enable = true;
        opencode.installDesktop = true;
      };

      prompts = {
        ohMyPosh.enable = true;
        spaceship.enable = false;
      };

      desktop.spotify.enable = true;
      terminals.wezterm = {
        enable = true;
        profile = "macbook";
        theme.flavor = "mocha";
        keys.mode = "leader";
        font.family = "Monaspace Neon";
        font.size = 14.0;
      };

      editors.neovim = {
        languages = {
          csharp = true;
        };
      };
    };
  };
}
