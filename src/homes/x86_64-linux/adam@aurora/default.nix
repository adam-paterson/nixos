{pkgs, ...}: {
  home.username = "adam";
  home.homeDirectory = "/home/adam";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  local.onePasswordSSH.enable = false;
  local.opencode = {
    enable = true;
    installDesktop = false;
  };

  local.openclaw = {
    enable = true;
    installApp = false;
    settingsFile = ../../../config/openclaw/shared.json;
  };

  home.packages = with pkgs; [
    tmux
  ];
}
