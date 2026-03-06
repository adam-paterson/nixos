{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.delta;
in {
  options.${namespace}.home.cli.delta.enable = lib.mkEnableOption "delta";

  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;
    };
  };
}
