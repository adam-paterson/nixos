{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.codex;
  sourceConfig =
    if cfg.settingsFile != null
    then cfg.settingsFile
    else ../../../../config/codex/config.toml;
  exportDefault =
    if cfg.settingsFile != null
    then toString cfg.settingsFile
    else "";
  exportScript = pkgs.writeShellScriptBin "codex-export-config" ''
    set -euo pipefail

    source_path="${cfg.stateDir}/config.toml"
    target_path="''${1:-${exportDefault}}"

    if [ ! -f "$source_path" ]; then
      echo "Codex config not found at $source_path" >&2
      exit 1
    fi

    if [ -z "$target_path" ]; then
      echo "Usage: codex-export-config <target-toml-path>" >&2
      echo "Tip: set local.codex.settingsFile to define a default target." >&2
      exit 2
    fi

    mkdir -p "$(dirname "$target_path")"
    cp "$source_path" "$target_path"
    echo "Exported Codex config to $target_path"
  '';
in {
  options.local.codex = {
    enable = lib.mkEnableOption "Codex config sync";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.codex";
      description = "Codex state directory (contains config.toml).";
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to source config.toml file. Defaults to src/config/codex/config.toml.";
    };

    overwriteExisting = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Overwrite ~/.codex/config.toml on activation. Disabled by default to keep Codex runtime state writable.";
    };

    installExportHelper = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install codex-export-config helper to copy live config back into the repo TOML.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.installExportHelper exportScript;

    home.activation.codexSeedConfig = ''
      target_path="${cfg.stateDir}/config.toml"
      source_path="${sourceConfig}"

      mkdir -p "${cfg.stateDir}"

      if [ "${
        if cfg.overwriteExisting
        then "1"
        else "0"
      }" = "1" ] || [ ! -e "$target_path" ]; then
        cp "$source_path" "$target_path"
      fi
    '';
  };
}
