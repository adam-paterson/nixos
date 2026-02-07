{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.local.opencode;
  system = pkgs.stdenv.hostPlatform.system;
  desktopEval =
    if inputs ? opencode
    then builtins.tryEval inputs.opencode.packages.${system}.desktop.drvPath
    else {
      success = false;
      value = null;
    };
  opencodeDesktop =
    if desktopEval.success
    then inputs.opencode.packages.${system}.desktop
    else null;
in {
  options.local.opencode = {
    enable = lib.mkEnableOption "OpenCode CLI";

    manageConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Manage ~/.config/opencode/opencode.json with Home Manager.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        "$schema" = "https://opencode.ai/config.json";
        theme = "opencode";
        permission = {
          "*" = "ask";
          bash = "allow";
          edit = "ask";
          webfetch = "ask";
        };
      };
      description = "OpenCode JSON settings rendered to ~/.config/opencode/opencode.json.";
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to an existing opencode.json file to source instead of generating from `settings`.";
    };

    installDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install OpenCode desktop package (recommended for macOS only).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [pkgs.opencode]
      ++ lib.optional (cfg.installDesktop && opencodeDesktop != null) opencodeDesktop;

    xdg.enable = true;

    xdg.configFile."opencode/opencode.json" = lib.mkIf cfg.manageConfig {
      source = lib.mkIf (cfg.settingsFile != null) cfg.settingsFile;
      text = lib.mkIf (cfg.settingsFile == null) (builtins.toJSON cfg.settings);
    };

    warnings = lib.optional (cfg.installDesktop && opencodeDesktop == null) ''
      local.opencode.installDesktop=true, but the upstream OpenCode desktop package is currently unavailable for ${system}.
      Falling back to CLI-only install.
    '';
  };
}
