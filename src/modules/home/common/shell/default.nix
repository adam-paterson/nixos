{lib, ...}: let
  sharedAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    gst = "git status -sb";
    glog = "git log --oneline --graph";
    vim = "nvim";
  };
in {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = lib.mkDefault true;
    enableCompletion = true;
    shellAliases = sharedAliases;
  };

  programs.zsh = {
    enable = lib.mkDefault true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = sharedAliases;
  };

  programs.nushell = {
    enable = true;
    shellAliases = sharedAliases;
  };

  home.sessionVariables = {
    TERM = "xterm-ghostty";
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
  };
}
