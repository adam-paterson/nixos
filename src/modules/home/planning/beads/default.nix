{
  config,
  pkgs,
  lib,
  namespace,
  inputs,
  ...
}: let
  cfg = config.${namespace}.home.planning.beads;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.${namespace}.home.planning.beads = {
    enable = lib.mkEnableOption "Beads integration";
    enableViewer = lib.mkEnableOption "Enable Beads viewer integration";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        inputs.agents.packages.${system}.beads
      ]
      ++ lib.optionals cfg.enableViewer [
        inputs.agents.packages.${system}.beads-viewer
      ];

    # Deploy a carapace bridge spec so nushell (and other shells using carapace)
    # get full completions for `bd` via Cobra's __complete endpoint.
    xdg.configFile."carapace/specs/bd.yaml".text = ''
      # yaml-language-server: $schema=https://carapace.sh/schemas/command.json
      name: bd
      description: Beads issue tracker CLI
      parsing: disabled
      completion:
        positionalany: ["$carapace.bridge.Cobra([bd])"]
    '';
  };
}
