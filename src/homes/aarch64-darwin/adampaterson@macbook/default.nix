{ pkgs, ... }:
{
  home.username = "adampaterson";
  home.homeDirectory = "/Users/adampaterson";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  local.onePasswordSSH.enable = true;

  local.opencode = {
    enable = true;
    installDesktop = true;
  };

  home.packages = with pkgs; [
    just
  ];
}
