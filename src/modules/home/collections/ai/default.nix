{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.collections.ai;
in {
  options.${namespace}.home.collections.ai.enable = lib.mkEnableOption "AI tooling home collection";

  config = lib.mkIf cfg.enable {
    ${namespace}.home = {
      cli.opencode.enable = lib.mkDefault true;
      editors.neovim.enableAI = lib.mkDefault true;
    };
  };
}
