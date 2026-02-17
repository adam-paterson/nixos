{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cosmos.openclaw;
in {
  options.cosmos.openclaw.enable = lib.mkEnableOption "OpenClaw Home Manager module";

  imports = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      enable = true;
      package = pkgs.openclaw;
    };
  };
}
