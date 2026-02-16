{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.nixos.base;
in {
  options.local.collections.nixos.base.enable = lib.mkEnableOption "baseline NixOS collection";

  config = lib.mkIf cfg.enable {
    imports = [
      ../../../base.nix
    ];
  };
}
