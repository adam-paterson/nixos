{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    ripgrep
    fd
    fzf
    jq
    bat
    eza
    htop
    tree
    unzip
    p7zip
  ];

  environment.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    lt = "eza --tree";
    g = "git";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline";
  };
}
