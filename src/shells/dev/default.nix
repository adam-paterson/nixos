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
          nixd
          alejandra
          statix
          deadnix
          git
          just
        ];

        # Set up git hooks for code quality checks.
        git-hooks.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      }
    )
  ];
}
