{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.nixos.workstation;
in {
  options.local.collections.nixos.workstation.enable =
    lib.mkEnableOption "workstation NixOS collection";

  config = lib.mkIf cfg.enable {
    local.collections.nixos.base.enable = lib.mkDefault true;
  };
}
