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
  };
in {
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
}
