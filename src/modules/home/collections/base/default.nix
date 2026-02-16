{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.base;
in {
  options.local.collections.home.base.enable = lib.mkEnableOption "baseline home collection";

  config = lib.mkIf cfg.enable {
    local = {
      git.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
      onePasswordCLI.enable = lib.mkDefault true;
      onePasswordSSH.enable = lib.mkDefault true;
      prompts.spaceship.enable = lib.mkDefault true;
    };
  };
}
