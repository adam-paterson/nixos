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
        btop.enable = true;
        delta.enable = true;
      };

      prompts = {
        ohMyPosh.enable = true;
        spaceship.enable = false;
      };

      theme = {
        enable = true;
        accent = "red";
        flavor = "mocha";
      };

      desktop.spotify.enable = true;
      terminals.wezterm = {
        enable = true;
        profile = "macbook";
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
