# Base Configuration - Common packages for ALL systems
# This works on both Darwin (macOS) and NixOS (Linux)

{ config, pkgs, lib, ... }:

{
  # Common packages available on all machines
  environment.systemPackages = with pkgs; [
    # Core utilities
    git
    vim
    curl
    wget
    
    # Modern CLI tools
    ripgrep      # Better grep
    fd           # Better find
    fzf          # Fuzzy finder
    jq           # JSON processor
    bat          # Better cat
    eza          # Better ls
    
    # System tools
    htop
    tree
    
    # Archives
    unzip
    p7zip
    
    # Network
    dnsutils
    inetutils
  ];

  # Common shell aliases for all systems
  environment.shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    
    # Modern replacements
    "cat" = "bat";
    "ls" = "eza";
    "ll" = "eza -la";
    "la" = "eza -a";
    "lt" = "eza --tree";
    
    # Git shortcuts
    "g" = "git";
    "ga" = "git add";
    "gc" = "git commit";
    "gp" = "git push";
    "gs" = "git status";
    "gd" = "git diff";
    "gl" = "git log --oneline";
  };
}
