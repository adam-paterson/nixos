{pkgs, ...}: {
  imports = [
    ../../common
  ];

  home = {
    username = "adam";
    homeDirectory = "/home/adam";
    stateVersion = "26.05";
  };

  local.onePasswordSSH.enable = true;

  local.neovim.enableDAP = true;

  home.packages = with pkgs; [
    tmux
  ];
}
