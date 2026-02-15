{
  pkgs,
  inputs,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      {pkgs, ...}: {
        # Ensure flake evaluation in CI has a stable root for devenv.
        devenv.root = toString ../../..;

        cachix.pull = ["adam-paterson"];

        packages = with pkgs; [
          nixd
          alejandra
          statix
          deadnix
          git
        ];

        tasks = {
          fmt = {
            description = "Format Nix files with alejandra.";
            exec = "nix run nixpkgs#alejandra -- .";
          };

          "fmt-check" = {
            description = "Check formatting with alejandra.";
            exec = "nix run nixpkgs#alejandra -- --check .";
          };

          lint = {
            description = "Lint Nix files with deadnix.";
            exec = "nix run nixpkgs#deadnix -- .";
          };

          fix = {
            description = "Apply formatting and lint autofixes.";
            exec = ''
              nix run nixpkgs#alejandra -- .
              nix run nixpkgs#statix -- fix .
              nix run nixpkgs#deadnix -- --edit .
            '';
          };

          check = {
            description = "Show flake outputs to verify evaluation.";
            exec = "nix flake show path:.";
          };

          eval = {
            description = "Evaluate key NixOS and Home Manager attributes.";
            exec = ''
              nix eval .#nixosConfigurations.aurora.config.networking.hostName
              nix eval .#nixosConfigurations.aurora.config.system.stateVersion
              nix eval .#darwinConfigurations.macbook.config.networking.hostName
              nix eval '.#nixosConfigurations.aurora.config.home-manager.users.adam.home.activationPackage.drvPath'
              nix eval '.#homeConfigurations."adampaterson@macbook".activationPackage.drvPath'
            '';
          };

          "build-aurora" = {
            description = "Dry-run build of aurora Home Manager activation package.";
            exec = "nix build '.#nixosConfigurations.aurora.config.home-manager.users.adam.home.activationPackage' --dry-run";
          };

          "build-macbook" = {
            description = "Dry-run build of macbook Home Manager activation package.";
            exec = "nix build '.#homeConfigurations.\"adampaterson@macbook\".activationPackage' --dry-run";
          };

          "switch-macbook" = {
            description = "Switch nix-darwin system configuration on macbook.";
            exec = "nix run nix-darwin -- switch --flake path:.#macbook";
          };

          "switch-aurora" = {
            description = "Switch aurora using remote build/target host over SSH.";
            exec = ''
              if [ "''${EUID}" -eq 0 ]; then
                echo "Run 'devenv tasks run switch-aurora' as your normal user (not via sudo)." >&2
                exit 1
              fi

              aurora_user="adam"
              aurora_host="aurora-1.taileb2c54.ts.net"
              nix run nixpkgs#nixos-rebuild -- switch --flake path:.#aurora --build-host "''${aurora_user}@''${aurora_host}" --target-host "''${aurora_user}@''${aurora_host}" --sudo --ask-sudo-password
            '';
          };

          ci = {
            description = "Run local CI checks (format, lint, flake show, eval).";
            exec = "true";
            after = ["fmt-check" "lint" "check" "eval"];
          };

          "test-openclaw-aurora" = {
            description = "OpenClaw eval smoke tests for aurora.";
            exec = ''
              nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances' | jq -e 'has("adam") and has("rachel") and (has("default") | not)'
              nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances.adam.gatewayPort' | jq -e '. == 18789'
              nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.programs.openclaw.instances.rachel.gatewayPort' | jq -e '. == 18810'
              nix eval --json '.#nixosConfigurations."aurora".config.home-manager.users.adam.home.file' | jq -e 'has(".openclaw-adam/openclaw.json") and has(".openclaw-rachel/openclaw.json") and has("/home/adam/.config/systemd/user/openclaw-gateway-adam.service") and has("/home/adam/.config/systemd/user/openclaw-gateway-rachel.service")'
              echo "OpenClaw aurora eval smoke test passed."
            '';
          };

          "build-aurora-system" = {
            description = "Dry-run build of full aurora NixOS system closure.";
            exec = "nix build '.#nixosConfigurations.\"aurora\".config.system.build.toplevel' --dry-run";
          };

          "predeploy-openclaw" = {
            description = "Recommended predeploy checks for OpenClaw on aurora.";
            exec = "true";
            after = ["fmt-check" "lint" "test-openclaw-aurora" "build-aurora-system"];
          };

          "cache-targets-linux" = {
            description = "Build Linux cache targets used by CI.";
            exec = "nix build --no-link '.#devShells.x86_64-linux.default' '.#nixosConfigurations.aurora.config.system.build.toplevel'";
          };

          "cache-targets-macos" = {
            description = "Build macOS cache targets used by CI.";
            exec = "nix build --no-link '.#devShells.aarch64-darwin.default' '.#darwinConfigurations.macbook.system' '.#homeConfigurations.\"adampaterson@macbook\".activationPackage'";
          };

          "container-build-image" = {
            description = "Build local Linux test image for Apple's container runtime.";
            exec = ''
              container_image="nixos-config-test:latest"
              container build -f Containerfile -t "''${container_image}" .
            '';
          };

          "container-build-image-amd64" = {
            description = "Build an amd64 image for Rosetta-backed x86_64 Linux testing.";
            exec = ''
              container_image_amd64="nixos-config-test:amd64"
              container build --platform linux/amd64 -f Containerfile -t "''${container_image_amd64}" .
            '';
          };

          "container-build-aurora-system" = {
            description = "Evaluate/build aurora system closure in container.";
            exec = ''
              aurora_user="adam"
              aurora_host="aurora-1.taileb2c54.ts.net"
              container_image="nixos-config-test:latest"
              container_image_amd64="nixos-config-test:amd64"

              if container run --rm --arch amd64 --rosetta "''${container_image_amd64}" uname -m >/dev/null 2>&1; then
                container run --rm --arch amd64 --rosetta --volume "$PWD:/work" --workdir /work "''${container_image_amd64}" bash -lc 'nix build .#nixosConfigurations.aurora.config.system.build.toplevel --print-out-paths'
              else
                echo "Local linux/amd64 image is not available or not runnable on this machine."
                echo "Build it first with: devenv tasks run container-build-image-amd64"
                echo "Running eval-only dry-run in linux/arm64 instead..."
                container run --rm --volume "$PWD:/work" --workdir /work "''${container_image}" bash -lc 'nix build .#nixosConfigurations.aurora.config.system.build.toplevel --dry-run'
                echo ""
                echo "For a full x86_64-linux build, use remote build on aurora:"
                echo "  nix run nixpkgs#nixos-rebuild -- build --flake path:.#aurora --build-host ''${aurora_user}@''${aurora_host} --target-host ''${aurora_user}@''${aurora_host} --sudo --ask-sudo-password"
              fi
            '';
          };
        };

        # Set up git hooks for code quality checks.
        git-hooks.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;

          "fmt-check" = {
            enable = true;
            name = "fmt-check";
            entry = "devenv tasks run fmt-check";
            pass_filenames = false;
          };
        };
      }
    )
  ];
}
