{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.cachix;
in {
  options.${namespace}.home.cli.cachix.enable = lib.mkEnableOption "Cachix";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.cachix];
  };
}
