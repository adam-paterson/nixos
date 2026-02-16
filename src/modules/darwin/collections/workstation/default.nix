{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.darwin.workstation;
in {
  options.local.collections.darwin.workstation.enable =
    lib.mkEnableOption "workstation Darwin collection";

  config = lib.mkIf cfg.enable {
    local.collections.darwin.base.enable = lib.mkDefault true;
  };
}
