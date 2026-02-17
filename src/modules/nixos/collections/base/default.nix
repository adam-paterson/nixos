{lib, ...}: {
  imports = [
    ../../../base.nix
  ];

  options.cosmos.collections.nixos.base.enable = lib.mkEnableOption "baseline NixOS collection";
}
