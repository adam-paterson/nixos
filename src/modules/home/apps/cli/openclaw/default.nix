{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.local.openclaw;
in {
  options.local.openclaw.enable = lib.mkEnableOption "OpenClaw Home Manager module";

  imports = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      enable = true;
    };
  };
}
