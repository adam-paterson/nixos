{
  namespace,
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.${namespace}.home.utilities.qmd;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.${namespace}.home.utilities.qmd = {
    enable = lib.mkEnableOption "QMD";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.agents.packages.${system}.qmd
    ];
  };
}
