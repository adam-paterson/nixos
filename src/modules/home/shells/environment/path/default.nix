{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.environment.path;
in {
  options.${namespace}.home.shells.environment.path.enable = lib.mkEnableOption "Shell path and editor environment defaults";

  config = lib.mkIf cfg.enable {
    home.sessionPath = [
      "$HOME/.nix-profile/bin"
    ];

    home.sessionVariables = {
      EDITOR = lib.mkDefault "nvim";
      GIT_EDITOR = lib.mkDefault "nvim";
    };
  };
}
