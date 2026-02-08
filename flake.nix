{
  description = "Cross-platform development environments with Snowfall Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    snowfall-lib = {
      # Name must stay `snowfall-lib` for mkFlake input discovery.
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "adam";
        root = ./src;
        meta = {
          name = "nixos-config";
          title = "NixOS Config";
        };
        alias = {
          shells.default = "dev";
        };
      };

      overlays = [
        (final: prev: let
          version = "0.98.0";
          releaseTag = "rust-v${version}";
          assets = {
            x86_64-linux = {
              triple = "x86_64-unknown-linux-musl";
              hash = "sha256-wJ7m7G8e71iCS96hTvsQre5U4OPFzL+k4/862bDd3IM=";
            };
            aarch64-darwin = {
              triple = "aarch64-apple-darwin";
              hash = "sha256-PMdXcogDruDEyZTFaCENmQCrxs7GC+Aj57LApuMBglU=";
            };
          };
          selectedAsset = assets.${final.stdenv.hostPlatform.system} or null;
        in {
          codex =
            if selectedAsset == null
            then prev.codex
            else
              final.stdenvNoCC.mkDerivation {
                pname = "codex";
                inherit version;

                src = final.fetchurl {
                  url = "https://github.com/openai/codex/releases/download/${releaseTag}/codex-${selectedAsset.triple}.tar.gz";
                  hash = selectedAsset.hash;
                };

                sourceRoot = ".";
                dontConfigure = true;
                dontBuild = true;

                installPhase = ''
                  runHook preInstall
                  mkdir -p "$out/bin"
                  cp "codex-${selectedAsset.triple}" "$out/bin/codex"
                  chmod +x "$out/bin/codex"
                  runHook postInstall
                '';

                meta =
                  prev.codex.meta
                  // {
                    inherit version;
                    sourceProvenance = [final.lib.sourceTypes.binaryNativeCode];
                  };
              };
        })
        inputs.nix-openclaw.overlays.default
      ];

      channels-config = {
        allowUnfree = true;
      };
    };
}
