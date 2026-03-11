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

    # Native zsh completion via Cobra's built-in generator.
    # This gives full flag+subcommand completion in zsh without the carapace
    # spec limitation where flags only appear after typing "-".
    programs.zsh.initContent = lib.mkAfter ''
      source <(bd completion zsh)
    '';

    # Carapace bridge spec for nushell (and any other carapace-integrated shell).
    # Nushell has no native Cobra completion support, so we use the carapace
    # bridge. Limitation: flags appear only after typing "-"; subcommand listing
    # works at any position.
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
