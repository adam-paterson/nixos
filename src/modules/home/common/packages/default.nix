{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    nushell
    gh
    ripgrep
    fd
    jq
    bat
    fzf
  ];
}
