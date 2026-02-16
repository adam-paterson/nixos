{pkgs, ...}: {
  cachix.pull = ["adam-paterson"];

  scripts = {
    fmt-check.exec = ''
      set -euo pipefail
      ${pkgs.alejandra}/bin/alejandra --check .
    '';

    lint.exec = ''
      set -euo pipefail
      ${pkgs.deadnix}/bin/deadnix --fail .
      ${pkgs.statix}/bin/statix check .
    '';

    check.exec = ''
      set -euo pipefail
      nix flake check "path:$PWD" --show-trace
    '';

    eval.exec = ''
      set -euo pipefail
      nix eval "path:$PWD#nixosConfigurations.aurora.config.system.build.toplevel.drvPath" >/dev/null
      nix eval "path:$PWD#darwinConfigurations.macbook.system.drvPath" >/dev/null
      nix eval "path:$PWD#homeConfigurations.\"adampaterson@macbook\".activationPackage.drvPath" >/dev/null
      nix eval "path:$PWD#homeConfigurations.\"adam@aurora\".activationPackage.drvPath" >/dev/null
    '';

    fix.exec = ''
      set -euo pipefail
      ${pkgs.alejandra}/bin/alejandra .
      ${pkgs.deadnix}/bin/deadnix --edit .
      ${pkgs.statix}/bin/statix fix .
    '';

    ci.exec = ''
      set -euo pipefail
      fmt-check
      lint
      check
      eval
    '';

    cache-targets-linux.exec = ''
      set -euo pipefail
      nix build --print-build-logs --no-link \
        .#devShells.x86_64-linux.dev \
        .#nixosConfigurations.aurora.config.system.build.toplevel
    '';

    cache-targets-macos.exec = ''
      set -euo pipefail
      nix build --print-build-logs --no-link \
        .#devShells.aarch64-darwin.dev \
        .#darwinConfigurations.macbook.system \
        '.#homeConfigurations."adampaterson@macbook".activationPackage'
    '';

    ubuntu-build-aurora.exec = ''
      set -euo pipefail
      nix build --print-build-logs --no-link \
        .#nixosConfigurations.aurora.config.system.build.toplevel
    '';
  };
}
