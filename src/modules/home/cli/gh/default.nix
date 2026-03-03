{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.gh;
in {
  options.${namespace}.home.cli.gh.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.gh];
  };
}
