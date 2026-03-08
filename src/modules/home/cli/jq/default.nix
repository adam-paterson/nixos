{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.jq;
in {
  options.${namespace}.home.cli.jq.enable = lib.mkEnableOption "jq";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.jq];
  };
}
