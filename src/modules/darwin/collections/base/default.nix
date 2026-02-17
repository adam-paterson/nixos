{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../../base.nix
    inputs.homebrew.darwinModules.nix-homebrew
  ];

  options.local.collections.darwin.base.enable = lib.mkEnableOption "baseline Darwin collection";
}
