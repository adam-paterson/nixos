# Home Manager Configuration for macbook
{ config, pkgs, lib, ... }:

{
  home.username = "adampaterson";
  home.homeDirectory = "/Users/adampaterson";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    fzf
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Adam Paterson";
    settings.user.email = "adam@example.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
