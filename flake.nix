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
      niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
    '';
    extra-substituters = ''
      https://devenv.cachix.org
      https://adam-paterson.cachix.org
      https://cache.numtide.com
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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home Manager (user-level package management)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (macOS support)
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI Coding Agents - https://github.com/numtide/llm-agents.nix
    agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gastown - multi-agent workspace manager - https://github.com/steveyegge/gastown
    gastown = {
      url = "github:steveyegge/gastown";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ──[ Snowfall Lib Inputs ]────────────────────────────────────────────
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    openclaw = {
      url = "github:openclaw/nix-openclaw";
    };

    devenv = {
      url = "github:cachix/devenv";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    catppuccin.url = "github:catppuccin/nix";
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
