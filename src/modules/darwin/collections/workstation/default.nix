{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.darwin.workstation;
in {
  options.cosmos.collections.darwin.workstation.enable =
    lib.mkEnableOption "workstation Darwin collection";

  config = lib.mkIf cfg.enable {
    cosmos.collections.darwin.base.enable = lib.mkDefault true;
    cosmos.overrides.darwin.macbook.enable = lib.mkDefault true;
  };
}
