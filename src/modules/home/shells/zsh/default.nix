{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.zsh;
  modernAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ls = "eza";
    ll = "eza -gl";
    la = "eza -gla";
    lt = "eza -T";
    tail = "tspin";
    gst = "git status -sb";
    glog = "git log --oneline --graph";
    vim = "nvim";
  };
in {
  options.${namespace}.home.shells.zsh.enable = lib.mkEnableOption "Zsh shell configuration";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = lib.mkDefault true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = modernAliases;
    };
  };
}
