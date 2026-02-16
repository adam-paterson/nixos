{
  lib,
  pkgs,
  inputs,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (_: {
      devenv.root = lib.mkForce "/tmp/devenv-nixos-config";
    })
    (import ../common {inherit pkgs;})
    (
      {pkgs, ...}: {
        packages = with pkgs; [
          alejandra
          statix
          deadnix
          just
          git
        ];
      }
    )
  ];
}
