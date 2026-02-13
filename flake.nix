# ╭──────────────────────────────────────────────────────────╮
# │ Nix flake (Snowfall Lib)                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "Cross-platform development environments with Snowfall Lib";
  # ── Inputs ────────────────────────────────────────────────────────────
  inputs = {
    # ── Primary Inputs ──────────────────────────────────────────────────
    # Nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Snowfall Lib
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix Darwin (macOS support)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home Manager (user-level package management)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Homebrew (macOS package manager)
    homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    # Homebrew packages and casks
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    openclaw-tools = {
      url = "github:openclaw/nix-steipete-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {...}: let
    meta = import ./meta.nix {inherit inputs;};
  in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "adampaterson";
        root = ./src;
        meta = {
          name = "nixos-config";
          title = "NixOS Config";
        };
        entities = meta;
      };

      alias = {
        shells.default = "dev";
      };

      overlays = [
        inputs.codex-cli-nix.overlays.default
        inputs.openclaw.overlays.default
      ];

      channels-config = {
        allowUnfree = true;
      };
    };
}
