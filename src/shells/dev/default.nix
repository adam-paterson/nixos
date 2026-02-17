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
              nix eval "path:''$PWD#nixosConfigurations.aurora.config.system.build.toplevel.drvPath" >/dev/null
              nix eval "path:''$PWD#darwinConfigurations.macbook.system.drvPath" >/dev/null
              nix eval "path:''$PWD#homeConfigurations.\"adampaterson@macbook\".activationPackage.drvPath" >/dev/null
              nix eval "path:''$PWD#homeConfigurations.\"adam@aurora\".activationPackage.drvPath" >/dev/null
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
