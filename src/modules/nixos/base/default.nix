{ ... }:
{
  imports = [
    ../../base.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
