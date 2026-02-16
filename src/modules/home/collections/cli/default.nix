{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.cli;
in {
  options.local.collections.home.cli.enable = lib.mkEnableOption "CLI apps home collection";

  config = lib.mkIf cfg.enable {
    local = {
      opencode.enable = lib.mkDefault true;
    };
  };
}
