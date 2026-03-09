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
        proxyVendor = true;
      }))
      # dolt 1.82.4+ required by gt doctor; nixpkgs only has 1.81.2 as of 2026-03
      (pkgs.dolt.overrideAttrs (_: {
        version = "1.83.2";
        src = pkgs.fetchFromGitHub {
          owner = "dolthub";
          repo = "dolt";
          tag = "v1.83.2";
          hash = "sha256-WKsvKZVn4o870w5sv0owmtm/Od2nhzvZOW/aV1jLysM=";
        };
        # icu4c-dev required by CGO go-icu-regex (unicode/uregex.h).
        buildInputs = [pkgs.icu76.dev];
        vendorHash = "sha256-v3WAiQjYxkzfgoC29M+4U4eG/HNqjdhPkqRGB3ESEgM=";
      }))
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
