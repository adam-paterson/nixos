# Git Configuration
# Shared across all hosts

{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    # Git configuration
    settings = {
      # TODO: Replace with your information
      user = {
        name = "Your Name";
        email = "your.email@example.com";
      };
      
      # Git aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      
      init = {
        defaultBranch = "main";
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      pull = {
        rebase = true;
      };
      core = {
        editor = "vim";
      };
      # Uncomment if you want to use SSH for GitHub
      # url = {
      #   "ssh://git@github.com/" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };
    };
    
    # Git ignore patterns (global)
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv/"
      "result"
      "result-*"
    ];
  };
}
