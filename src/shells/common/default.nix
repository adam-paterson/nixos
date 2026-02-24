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

      list_hosts() {
        local attr=$1
        nix eval --raw --apply 'hosts: builtins.concatStringsSep "\n" (builtins.attrNames hosts)' "path:$PWD#''${attr}"
      }

      eval_hosts() {
        local attr=$1
        local suffix=$2
        local hosts=$3

        while IFS= read -r host; do
          [ -n "$host" ] || continue
          nix eval "path:$PWD#''${attr}.''${host}.''${suffix}" >/dev/null
        done <<< "$hosts"
      }

      darwin_hosts=$(list_hosts darwinConfigurations)
      nixos_hosts=$(list_hosts nixosConfigurations)

      eval_hosts darwinConfigurations system.drvPath "$darwin_hosts"
      eval_hosts nixosConfigurations config.system.build.toplevel.drvPath "$nixos_hosts"
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
