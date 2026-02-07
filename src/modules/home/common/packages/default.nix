{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    nushell
    ripgrep
    fd
    jq
    bat
    fzf
  ];
}
