{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.desktop;
in {
  options.local.collections.home.desktop.enable = lib.mkEnableOption "desktop apps home collection";

  config = lib.mkIf cfg.enable {
    local = {
      ghostty.enable = lib.mkDefault true;
      oh-my-posh.enable = lib.mkDefault true;
    };
  };
}
