{lib, ...}: {
  imports = [
    ../../../base.nix
  ];

  options.local.collections.nixos.base.enable = lib.mkEnableOption "baseline NixOS collection";
}
