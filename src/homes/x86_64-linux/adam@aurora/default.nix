# Home Manager Configuration for Aurora
{ config, pkgs, lib, ... }:

{
  home.username = "adam";
  home.homeDirectory = "/home/adam";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
  ];

  programs.git = {
    enable = true;
    userName = "Adam Paterson";
    userEmail = "adam@example.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
