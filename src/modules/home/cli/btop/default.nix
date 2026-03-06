{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.btop;
in {
  options.${namespace}.home.cli.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
    };
  };
}
