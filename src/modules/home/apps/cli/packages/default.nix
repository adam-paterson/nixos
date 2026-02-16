{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    nushell
    direnv
    nixd
    gh
    codex
    ripgrep
    fd
    jq
    bat
    fzf
    delta
    cachix
  ];
}
