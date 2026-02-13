{inputs, ...}: {
  imports = [
    ../../base.nix
    inputs.homebrew.darwinModules.nix-homebrew
  ];
}
