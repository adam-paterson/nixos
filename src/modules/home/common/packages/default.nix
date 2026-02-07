{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    nushell
    direnv
    nixd
    gh
    ripgrep
    fd
    jq
    bat
    fzf
  ];
}
