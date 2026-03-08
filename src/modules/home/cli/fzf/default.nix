{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.fzf;
in {
  options.${namespace}.home.cli.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.fzf];
  };
}
