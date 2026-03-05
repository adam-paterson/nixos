{
  config,
  pkgs,
  lib,
  namespace,
  inputs,
  ...
}: let
  cfg = config.${namespace}.home.planning.gastown;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.${namespace}.home.planning.gastown = {
    enable = lib.mkEnableOption "Gastown multi-agent workspace manager";

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/gt";
      description = "Default Gas Town workspace directory (used for shell alias).";
    };

    defaultAgent = lib.mkOption {
      type = lib.types.enum [
        "claude"
        "codex"
        "gemini"
        "cursor"
        "auggie"
        "amp"
      ];
      default = "claude";
      description = "Default AI agent runtime for gt.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      # Override vendorHash: gastown's flake.nix pins v0.8.0 but the locked
      # commit has updated Go modules, so the upstream hash is stale.
      (inputs.gastown.packages.${system}.gt.overrideAttrs (_: {
        vendorHash = "sha256-/+ODyndArUF0nJY9r8G5JKhzQckBHFb48A7EBZmoIr0=";
      }))
      pkgs.dolt
      pkgs.go
    ];

    # Shell completions via carapace bridge (mirrors beads pattern for bd).
    # gt uses Cobra under the hood so the Cobra bridge works directly.
    xdg.configFile."carapace/specs/gt.yaml".text = ''
      # yaml-language-server: $schema=https://carapace.sh/schemas/command.json
      name: gt
      description: Gas Town multi-agent workspace manager
      parsing: disabled
      completion:
        positionalany: ["$carapace.bridge.Cobra([gt])"]
    '';
  };
}
