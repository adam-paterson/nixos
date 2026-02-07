{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  packages = with pkgs; [
    nixd
    alejandra
    nil
    statix
    deadnix
    just
  ];
}
