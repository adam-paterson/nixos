{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.nixos.workstation;
in {
  options.cosmos.collections.nixos.workstation.enable =
    lib.mkEnableOption "workstation NixOS collection";

  config = lib.mkIf cfg.enable {
    cosmos.collections.nixos.base.enable = lib.mkDefault true;
  };
}
