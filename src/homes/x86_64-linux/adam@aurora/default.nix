{pkgs, ...}: {
  imports = [
    ./openclaw
  ];

  home = {
    username = "adam";
    homeDirectory = "/home/adam";
    stateVersion = "26.05";
  };

  local = {
    onePasswordSSH.enable = true;

    collections.home = {
      base.enable = true;
      dev.enable = true;
      cli.enable = true;
      ai.enable = true;
    };

    neovim.enableDAP = true;
  };

  home.packages = with pkgs; [
    tmux
  ];
}
