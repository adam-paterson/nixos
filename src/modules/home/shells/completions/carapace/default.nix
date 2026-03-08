{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.completions.carapace;
in {
  options.${namespace}.home.shells.completions.carapace = {
    enable = lib.mkEnableOption "Carapace multi-shell completion";

    ignoreCase = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable case-insensitive completion matching via CARAPACE_MATCH=1.";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Carapace integration for Bash.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Carapace integration for Zsh.";
    };

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Carapace integration for Nushell.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      inherit (cfg) ignoreCase;
      inherit (cfg) enableBashIntegration;
      inherit (cfg) enableZshIntegration;
      inherit (cfg) enableNushellIntegration;
    };
  };
}
