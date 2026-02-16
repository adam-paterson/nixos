{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.local.collections.darwin.base;
in {
  options.local.collections.darwin.base.enable = lib.mkEnableOption "baseline Darwin collection";

  config = lib.mkIf cfg.enable {
    imports = [
      ../../../base.nix
      inputs.homebrew.darwinModules.nix-homebrew
    ];
  };
}
