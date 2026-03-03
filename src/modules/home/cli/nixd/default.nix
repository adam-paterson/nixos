{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.nixd;
in {
  options.${namespace}.home.cli.nixd.enable = lib.mkEnableOption "nixd";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.nixd];
  };
}
