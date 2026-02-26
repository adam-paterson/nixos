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

    secrets-scan.exec = ''
      set -euo pipefail

      scan_scope="''${SECRETS_SCAN_SCOPE:-staged}"
      base_ref="''${SECRETS_SCAN_BASE:-}"

      case "$scan_scope" in
        staged)
          mapfile -t candidate_files < <(git diff --cached --name-only --diff-filter=ACMR)
          ;;
        diff-base)
          if [ -z "$base_ref" ]; then
            printf '%s\n' "SECRETS_SCAN_BASE is required when SECRETS_SCAN_SCOPE=diff-base."
            exit 1
          fi
          mapfile -t candidate_files < <(git diff --name-only --diff-filter=ACMR "$base_ref...HEAD")
          ;;
        working-tree)
          mapfile -t candidate_files < <(git diff --name-only --diff-filter=ACMR)
          ;;
        full)
          mapfile -t candidate_files < <(git ls-files)
          ;;
        *)
          printf 'Unsupported SECRETS_SCAN_SCOPE: %s\n' "$scan_scope"
          exit 1
          ;;
      esac

      if [ "''${#candidate_files[@]}" -eq 0 ]; then
        printf 'No files to scan for scope %s.\n' "$scan_scope"
        exit 0
      fi

      tmp_config=$(mktemp)
      scan_root=$(mktemp -d)
      trap 'rm -f "$tmp_config"; rm -rf "$scan_root"' EXIT

      for file in "''${candidate_files[@]}"; do
        [ -f "$file" ] || continue
        mkdir -p "$scan_root/$(dirname "$file")"
        cp "$file" "$scan_root/$file"
      done

      cat >"$tmp_config" <<'EOF'
      title = "nixos-config gitleaks overrides"

      [extend]
      useDefault = true

      [[allowlists]]
      description = "Allow encrypted sops payload markers and documented mock placeholders"
      regexes = [
        "DUMMY_NOT_A_SECRET_[A-Z0-9_]+",
        "ENC\\[AES256_GCM,[^\\n]+",
        "-----BEGIN AGE ENCRYPTED FILE-----",
        "-----END AGE ENCRYPTED FILE-----"
      ]
      EOF

      scanned_count=$(find "$scan_root" -type f | wc -l | tr -d ' ')
      printf 'Running secrets scan (%s) on %s file(s).\n' "$scan_scope" "$scanned_count"

      if ! ${pkgs.gitleaks}/bin/gitleaks detect --source "$scan_root" --no-git --config "$tmp_config" --redact --exit-code 1; then
        printf '%s\n' "Secret scan failed. Remove plaintext credentials or move values into encrypted SOPS files."
        printf '%s\n' "Allowed patterns: encrypted SOPS payload markers and DUMMY_NOT_A_SECRET placeholders."
        exit 1
      fi
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

    flake-contract.exec = ''
      set -euo pipefail

      list_hosts() {
        local attr=$1
        nix eval --raw --apply 'hosts: builtins.concatStringsSep "\n" (builtins.attrNames hosts)' "path:$PWD#''${attr}"
      }

      eval_and_dry_build() {
        local attr=$1
        local eval_suffix=$2
        local build_suffix=$3
        local hosts=$4

        while IFS= read -r host; do
          [ -n "$host" ] || continue
          nix eval "path:$PWD#''${attr}.''${host}.''${eval_suffix}" >/dev/null
          nix build --dry-run "path:$PWD#''${attr}.''${host}.''${build_suffix}" >/dev/null
        done <<< "$hosts"
      }

      darwin_hosts=$(list_hosts darwinConfigurations)
      nixos_hosts=$(list_hosts nixosConfigurations)

      eval_and_dry_build darwinConfigurations system.drvPath system "$darwin_hosts"
      eval_and_dry_build nixosConfigurations config.system.build.toplevel.drvPath config.system.build.toplevel "$nixos_hosts"
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
      secrets-scan
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
