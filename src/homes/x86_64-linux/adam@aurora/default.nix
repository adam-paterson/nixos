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

      security.onePasswordCLI = {
        # Load all aurora environment variables from the named 1Password Environment.
        # Requires op environment read (CLI >= 2.33.0-beta.02) and OP_SERVICE_ACCOUNT_TOKEN.
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
