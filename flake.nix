# ╔══════════════════════════════════════════════════════════════════╗
# ║ flake.nix                                                        ║
# ║ Nix flake outputs: devShells, packages, checks, formatter        ║
# ╚══════════════════════════════════════════════════════════════════╝
{
  description = "Cross-platform development environments with Snowfall Lib";

  nixConfig = {
    extra-trusted-public-keys = ''
      devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      adam-paterson.cachix.org-1:kBJ4hRgKh5d2yEWnbCssWhcM/Ya+bDGnroeI0O0G5jk=
    '';
    extra-substituters = ''
      https://devenv.cachix.org
      https://adam-paterson.cachix.org
    '';
  };

  # ──[ Inputs ]──────────────────────────────────────────────────────────────
  # Dev shells + build outputs. Prefer `nix develop` or direnv `use flake`.
  # ──────────────────────────────────────────────────────────────────────────
  inputs = {
    # ──[ Nix Inputs ]────────────────────────────────────────────────────────
    # Official NixOS package source, using nixos's unstable branch by default.
    # Follow it in other flakes for consistency. Pinning to a specific commit
    # or branch ensures reproducibility.
    # ────────────────────────────────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # ──[ Snowfall Lib Inputs ]────────────────────────────────────────────
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

    codex = {
      url = "github:openai/codex";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    meta = import ./meta.nix {inherit inputs;};
  in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "cosmos";
        root = ./src;
        meta = {
          name = "cosmos";
          title = "Adam Paterson | Cosmos";
        };
        entities = meta;
      };

      overlays = [
        inputs.openclaw.overlays.default
      ];

      channels-config = {
        allowUnfree = true;
      };
    };
}
