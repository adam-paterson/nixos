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
          nh
          optnix
          nix-tree
          nvd
          nix-output-monitor
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

          secrets-scan = {
            enable = true;
            name = "secrets-scan";
            entry = "${pkgs.writeShellScript "secrets-scan" ''
              set -euo pipefail
              nix develop "path:''$PWD#ci" -c secrets-scan
            ''}";
            language = "system";
            files = ".*";
            pass_filenames = false;
          };
        };
      }
    )
  ];
}
