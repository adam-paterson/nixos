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
    collections.home = {
      base.enable = true;
      dev.enable = true;
      cli.enable = true;
      ai.enable = true;
    };

    neovim.enableDAP = true;

    # OpenClaw is a host-local gaming utility not shared across hosts.
    openclaw.enable = true;
  };
}
