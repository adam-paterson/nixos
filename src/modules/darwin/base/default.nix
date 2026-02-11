{inputs, ...}: {
  imports = [
    ../../base.nix
    inputs.homebrew.darwinModules.nix-homebrew
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
