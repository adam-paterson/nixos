{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.local.openclaw;
  inherit (pkgs.stdenv.hostPlatform) system;
  openclawPackages = inputs.nix-openclaw.packages.${system};
  defaultSettings = {
    gateway.mode = "local";
  };
  effectiveSettings =
    if cfg.settingsFile != null
    then builtins.fromJSON (builtins.readFile cfg.settingsFile)
    else cfg.settings;
  exportDefault =
    if cfg.settingsFile != null
    then toString cfg.settingsFile
    else "";
  exportScript = pkgs.writeShellScriptBin "openclaw-export-config" ''
    set -euo pipefail

    source_path="${cfg.stateDir}/openclaw.json"
    target_path="''${1:-${exportDefault}}"

    if [ ! -f "$source_path" ]; then
      echo "OpenClaw config not found at $source_path" >&2
      exit 1
    fi

    if [ -z "$target_path" ]; then
      echo "Usage: openclaw-export-config <target-json-path>" >&2
      echo "Tip: set local.openclaw.settingsFile to define a default target." >&2
      exit 2
    fi

    mkdir -p "$(dirname "$target_path")"
    cp "$source_path" "$target_path"
    echo "Exported OpenClaw config to $target_path"
  '';
in {
  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  options.local.openclaw = {
    enable = lib.mkEnableOption "OpenClaw via nix-openclaw";

    manageConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Manage OpenClaw JSON configuration via Nix.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = defaultSettings;
      description = "OpenClaw configuration as Nix attrs (used when settingsFile is null).";
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a JSON file loaded into programs.openclaw.config (takes precedence over settings).";
    };

    installApp = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isDarwin;
      description = "Install OpenClaw.app when available (macOS).";
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional OpenClaw documents directory containing AGENTS.md/SOUL.md/TOOLS.md.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.openclaw";
      description = "OpenClaw state directory.";
    };

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.openclaw/workspace";
      description = "OpenClaw workspace directory.";
    };

    installExportHelper = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install openclaw-export-config helper to copy live config back into repo JSON.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      enable = true;
      package = openclawPackages.openclaw;
      appPackage =
        openclawPackages.openclaw-app or null;
      inherit (cfg) installApp;
      inherit (cfg) stateDir;
      inherit (cfg) workspaceDir;
      inherit (cfg) documents;
      config = lib.mkIf cfg.manageConfig effectiveSettings;
    };

    home.packages = lib.optional cfg.installExportHelper exportScript;

    warnings =
      lib.optional (cfg.settingsFile != null) "local.openclaw.settingsFile is set; local.openclaw.settings is ignored."
      ++ lib.optional (!cfg.manageConfig && config.programs.openclaw.instances == {}) "local.openclaw.manageConfig=false; OpenClaw config will not be managed declaratively.";
  };
}
