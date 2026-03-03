{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.tailspin;
in {
  options.${namespace}.home.cli.tailspin.enable = lib.mkEnableOption "tailspin";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.tailspin];
  };
}
