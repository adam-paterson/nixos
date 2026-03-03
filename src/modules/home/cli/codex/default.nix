{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.codex;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.${namespace}.home.cli.codex = {
    enable = lib.mkEnableOption "Codex";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.agents.packages.${system}.codex
    ];
  };
}
