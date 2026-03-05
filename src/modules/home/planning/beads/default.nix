{
  config,
  pkgs,
  lib,
  namespace,
  inputs,
  ...
}:
let
  cfg = config.${namespace}.home.planning.beads;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.${namespace}.home.planning.beads = {
    enable = lib.mkEnableOption "Beads integration";
    enableViewer = lib.mkEnableOption "Enable Beads viewer integration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.agents.packages.${system}.beads
    ]
    ++ lib.optionals cfg.enableViewer [
      inputs.agents.packages.${system}.beads-viewer
    ];
  };
}
