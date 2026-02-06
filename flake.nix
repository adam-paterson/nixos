{
  description = "NixOS & Darwin configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./src;

      snowfall = {
        namespace = "adam-paterson";
        meta = {
          name = "adam-config";
          title = "Adam's NixOS Configuration";
        };
      };

      systems.modules.darwin = with inputs; [
        home-manager.darwinModules.default
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.default
      ];

      channels-config = {
        allowUnfree = true;
      };
    };
}
