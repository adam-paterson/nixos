{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.home.ai;
in {
  options.cosmos.collections.home.ai.enable = lib.mkEnableOption "AI tooling home collection";

  config = lib.mkIf cfg.enable {
    cosmos = {
      opencode.enable = lib.mkDefault true;
      neovim.enableAI = lib.mkDefault true;
    };
  };
}
