{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  packages = with pkgs; [
    direnv
    nixd
    alejandra
    nil
    statix
    deadnix
    just
  ];
}
