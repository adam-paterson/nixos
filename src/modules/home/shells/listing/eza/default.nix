{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.listing.eza;
in {
  options.${namespace}.home.shells.listing.eza.enable = lib.mkEnableOption "Eza modern ls replacement";

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--octal-permissions"
      ];
      git = true;
      icons = "always";
    };
  };
}
