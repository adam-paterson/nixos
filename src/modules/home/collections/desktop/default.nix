{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.collections.desktop;
in {
  options.${namespace}.home.collections.desktop.enable = lib.mkEnableOption "desktop apps home collection";

  config = lib.mkIf cfg.enable {
    ${namespace}.home = {
      terminals.ghostty.enable = lib.mkDefault true;
      desktop.spotify.enable = lib.mkDefault true;
      prompts.ohMyPosh.enable = lib.mkDefault true;
    };
  };
}
