# MacBook Home Configuration
{ config, pkgs, lib, ... }:

{
  # User info
  home.username = "adampaterson";
  home.homeDirectory = "/Users/adampaterson";
  home.stateVersion = "24.05";

  # Enable home-manager
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings.user.name = "Adam Paterson";
    settings.user.email = "adam@example.com";
    
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
    };
    
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Zsh configuration with aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "gaa" = "git add --all";
      "gcm" = "git commit -m";
      "gst" = "git status -sb";
      "glog" = "git log --oneline --graph";
    };
  };
}
