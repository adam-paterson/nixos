{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.codex;
in {
  options.cosmos.codex = {
    enable = lib.mkEnableOption "Codex";
  };

  config = lib.mkIf cfg.enable {
    programs.codex = {
      enable = true;
    };
  };
}
