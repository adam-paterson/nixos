{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.dev;
in {
  options.local.collections.home.dev.enable = lib.mkEnableOption "developer tooling home collection";

  config = lib.mkIf cfg.enable {
    local = {
      neovim.enable = lib.mkDefault true;
      tailwind.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
    };
  };
}
