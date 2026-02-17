{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.home.desktop;
in {
  options.cosmos.collections.home.desktop.enable = lib.mkEnableOption "desktop apps home collection";

  config = lib.mkIf cfg.enable {
    cosmos = {
      ghostty.enable = lib.mkDefault true;
      oh-my-posh.enable = lib.mkDefault true;
    };
  };
}
