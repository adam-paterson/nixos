{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../../base.nix
    inputs.homebrew.darwinModules.nix-homebrew
  ];

  options.cosmos.collections.darwin.base.enable = lib.mkEnableOption "baseline Darwin collection";
}
