{
  description = "NixOS & Darwin configurations with flakes";

  # Inputs - all external dependencies for this flake
  # See: .agents/skills/nixos-best-practices/rules/flakes-structure.md
  inputs = {
    # Main nixpkgs - using unstable for latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Stable nixpkgs for packages that need stability
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    
    # nix-darwin for macOS system configuration
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs, not darwin's own
    
    # Home Manager for user-level configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs
    
    # Agenix for encrypted secrets management
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs
  };

  # Outputs - what this flake produces
  # CRITICAL: Use @inputs pattern to capture all inputs
  # See: .agents/skills/nixos-best-practices/rules/flakes-structure.md
  outputs = { self, nixpkgs, nixpkgs-stable, darwin, home-manager, agenix, ... }@inputs:
    let
      # Helper function to create pkgs-stable for a given system
      mkPkgsStable = system: import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # ============================================================================
      # NixOS Configurations
      # ============================================================================
      # Build with: sudo nixos-rebuild switch --flake .#hostname
      
      nixosConfigurations = {
        # Example NixOS host - replace with your actual hostname
        example-nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          
          # CRITICAL: Pass inputs via specialArgs so modules can access them
          # See: .agents/skills/nixos-best-practices/rules/flakes-structure.md
          specialArgs = {
            inherit inputs;
            system = "x86_64-linux";
            pkgs-stable = mkPkgsStable "x86_64-linux";
          };
          
          modules = [
            ./hosts/example-nixos
          ];
        };
        
        # Add more NixOS hosts here following the same pattern
        # my-server = nixpkgs.lib.nixosSystem { ... };
      };

      # ============================================================================
      # Darwin (macOS) Configurations
      # ============================================================================
      # Build with: darwin-rebuild switch --flake .#hostname
      
      darwinConfigurations = {
        # Example Darwin host - replace with your actual hostname
        example-darwin = darwin.lib.darwinSystem {
          system = "aarch64-darwin";  # Use "x86_64-darwin" for Intel Macs
          
          # CRITICAL: Pass inputs via specialArgs so modules can access them
          # See: .agents/skills/nixos-best-practices/rules/flakes-structure.md
          specialArgs = {
            inherit inputs;
            system = "aarch64-darwin";  # Use "x86_64-darwin" for Intel Macs
            pkgs-stable = mkPkgsStable "aarch64-darwin";
          };
          
          modules = [
            ./hosts/example-darwin
          ];
        };
        
        # Add more Darwin hosts here following the same pattern
        # my-macbook = darwin.lib.darwinSystem { ... };
      };

      # ============================================================================
      # Formatters
      # ============================================================================
      # Enable `nix fmt` for formatting Nix files
      
      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
        x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixpkgs-fmt;
      };
    };
}
