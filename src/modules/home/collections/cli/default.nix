{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.collections.cli;
in {
  options.${namespace}.home.collections.cli.enable = lib.mkEnableOption "CLI apps home collection";

  config = lib.mkIf cfg.enable {
    ${namespace}.home.cli = {
      opencode = {
        enable = lib.mkDefault true;
        installDesktop = lib.mkDefault false;
      };
      codex.enable = lib.mkDefault true;
    };
  };
}
