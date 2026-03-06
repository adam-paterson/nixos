{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.viewers.bat;
in {
  options.${namespace}.home.shells.viewers.bat.enable = lib.mkEnableOption "Bat syntax-highlighting pager";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.bat.enable = true;
    }
  ]);
}
