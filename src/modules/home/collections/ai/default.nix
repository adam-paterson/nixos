{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.ai;
in {
  options.local.collections.home.ai.enable = lib.mkEnableOption "AI tooling home collection";

  config = lib.mkIf cfg.enable {
    local = {
      opencode.enable = lib.mkDefault true;
      neovim.enableAI = lib.mkDefault true;
    };
  };
}
