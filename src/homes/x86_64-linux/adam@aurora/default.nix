{ pkgs, ... }:
{
  home.username = "adam";
  home.homeDirectory = "/home/adam";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
  local.onePasswordSSH.enable = true;
  local.opencode = {
    enable = true;
    installDesktop = false;
  };

  home.packages = with pkgs; [
    tmux
  ];
}
