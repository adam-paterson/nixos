{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.home.cli;
in {
  options.cosmos.collections.home.cli.enable = lib.mkEnableOption "CLI apps home collection";

  config = lib.mkIf cfg.enable {
    cosmos = {
      opencode = {
        enable = lib.mkDefault true;
        installDesktop = lib.mkDefault false;
      };
    };
  };
}
