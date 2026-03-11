{
  config,
  pkgs,
  lib,
  namespace,
  inputs,
  ...
}: let
  cfg = config.${namespace}.home.planning.gastown;

  gtFixed = pkgs.buildGoModule {
    pname = "gt";
    version = "0.8.0";
    src = inputs.gastown;
    vendorHash = "sha256-fZucwy6omCXV5/ebOzcqOgJ4SfouCHasmstEX2na5SQ=";
    ldflags = [
      "-X github.com/steveyegge/gastown/internal/cmd.Build=nix"
      "-X github.com/steveyegge/gastown/internal/cmd.BuiltProperly=1"
    ];
    subPackages = ["cmd/gt"];
  };
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
      gtFixed
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

    # Native zsh completion via Cobra's built-in generator.
    # This gives full flag+subcommand completion in zsh without the carapace
    # spec limitation where flags only appear after typing "-".
    programs.zsh.initContent = lib.mkAfter ''
      source <(gt completion zsh)
    '';

    # Carapace bridge spec for nushell (and any other carapace-integrated shell).
    # gt uses Cobra under the hood so the Cobra bridge works directly.
    # Limitation: flags appear only after typing "-"; subcommand listing works
    # at any position.
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
