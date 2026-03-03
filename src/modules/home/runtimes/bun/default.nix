{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.runtimes.bun;

  effectivePackages = builtins.removeAttrs (cfg.globalPackages // cfg.extraGlobalPackages) cfg.disabledGlobalPackages;
  packageEntries =
    lib.mapAttrsToList (name: spec: {
      inherit name spec;
    })
    effectivePackages;

  installCommands =
    lib.concatMapStringsSep "\n" (entry: ''
      echo "Installing Bun global package '${entry.name}' from '${entry.spec}'..."
      if ! "${pkgs.bun}/bin/bun" add -g "${entry.spec}"; then
        echo "Failed to install Bun global package '${entry.name}' from '${entry.spec}'." >&2
        exit 1
      fi
    '')
    packageEntries;

  desiredKeys = builtins.attrNames effectivePackages;
  desiredKeyLines = lib.concatStringsSep "\n" desiredKeys;
in {
  options.${namespace}.home.runtimes.bun = {
    enable = lib.mkEnableOption "Bun runtime with declarative global package management";

    globalPackages = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = lib.literalExpression ''
        {
          beads = "github:steveyegge/beads";
          prettier = "prettier";
        }
      '';
      description = "Shared declarative Bun global packages (name -> bun install spec).";
    };

    extraGlobalPackages = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Host-local Bun global package additions (name -> bun install spec).";
    };

    disabledGlobalPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Package keys to remove from the effective Bun global package set for this host.";
    };

    reconcile = lib.mkOption {
      type = lib.types.enum [
        "install-only"
        "strict-prune"
        "audit-only"
      ];
      default = "install-only";
      description = "Reconciliation mode for Bun global package activation.";
    };

    installDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.bun";
      description = "BUN_INSTALL directory used for Bun global package installs.";
    };

    addBinToPath = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add BUN_INSTALL/bin to the shell PATH.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.bun
    ];

    home.sessionVariables = {
      BUN_INSTALL = cfg.installDir;
    };

    home.sessionPath = lib.mkIf cfg.addBinToPath [
      "${cfg.installDir}/bin"
    ];

    home.activation.cosmosBunGlobals = lib.mkAfter ''
            set -euo pipefail

            export PATH="${pkgs.bun}/bin:$PATH"
            export BUN_INSTALL="${cfg.installDir}"

            echo "Bun globals reconcile mode: ${cfg.reconcile}"
            echo "Using BUN_INSTALL=$BUN_INSTALL"

            case "${cfg.reconcile}" in
              audit-only)
                echo "Audit-only mode: no changes will be made."
                echo "Desired Bun global package keys:"
                cat <<'EOF'
      ${desiredKeyLines}
      EOF
                echo "---"
                "${pkgs.bun}/bin/bun" pm ls -g || true
                ;;

              install-only)
      ${installCommands}
                ;;

              strict-prune)
      ${installCommands}
                desired_keys_file="$(mktemp)"
                cat > "$desired_keys_file" <<'EOF'
      ${desiredKeyLines}
      EOF

            installed_packages="$("${pkgs.bun}/bin/bun" pm ls -g 2>/dev/null | sed -nE 's/^[[:space:]]*[^[:alnum:]]+[[:space:]]*([^@[:space:]]+).*/\1/p')"
                while IFS= read -r package_name; do
                  [ -z "$package_name" ] && continue
                  if ! grep -Fxq "$package_name" "$desired_keys_file"; then
                    echo "Removing unmanaged Bun global package '$package_name'..."
                    "${pkgs.bun}/bin/bun" remove -g "$package_name" || {
                      echo "Warning: failed to remove '$package_name' during strict-prune." >&2
                    }
                  fi
                done <<< "$installed_packages"

                rm -f "$desired_keys_file"
                ;;
            esac
    '';
  };
}
