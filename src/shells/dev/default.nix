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

        git-hooks.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;

          flake-eval = {
            enable = true;
            name = "flake-eval";
            entry = "${pkgs.writeShellScript "flake-eval" ''
              set -euo pipefail
              nix develop "path:''$PWD#ci" -c flake-contract
            ''}";
            language = "system";
            files = "\\.nix$";
            pass_filenames = false;
          };
        };
      }
    )
  ];
}
