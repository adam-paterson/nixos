{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.navigation.zoxide;
in {
  options.${namespace}.home.shells.navigation.zoxide.enable = lib.mkEnableOption "Zoxide directory navigation";

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = ["--cmd cd"];
    };
  };
}
