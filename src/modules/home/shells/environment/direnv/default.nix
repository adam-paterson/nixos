{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.environment.direnv;
in {
  options.${namespace}.home.shells.environment.direnv.enable = lib.mkEnableOption "Direnv and nix-direnv integration";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
