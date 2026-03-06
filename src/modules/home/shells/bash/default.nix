{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.bash;
  modernAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ll = "eza -gl";
    la = "eza -gla";
    lt = "eza -T";
    tail = "tspin";
    gst = "git status -sb";
    glog = "git log --oneline --graph";
    vim = "nvim";
  };
in {
  options.${namespace}.home.shells.bash.enable = lib.mkEnableOption "Bash shell configuration";

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = lib.mkDefault true;
      enableCompletion = true;
      shellAliases = modernAliases;
    };
  };
}
