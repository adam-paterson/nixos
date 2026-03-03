{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.ripgrep;
in {
  options.${namespace}.home.cli.ripgrep.enable = lib.mkEnableOption "ripgrep";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.ripgrep];
  };
}
