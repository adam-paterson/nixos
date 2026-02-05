# Shell Configuration
# Shared across all hosts

{ config, pkgs, ... }:

{
  # ============================================================================
  # Bash Configuration
  # ============================================================================
  
  programs.bash = {
    enable = true;
    
    shellAliases = {
      ll = "ls -alh";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
    
    initExtra = ''
      # Custom bash configuration
      # Add your custom bash code here
    '';
  };

  # ============================================================================
  # Zsh Configuration (Optional)
  # ============================================================================
  # Uncomment to enable Zsh instead of or alongside Bash
  
  # programs.zsh = {
  #   enable = true;
  #   
  #   shellAliases = {
  #     ll = "ls -alh";
  #     ".." = "cd ..";
  #     "..." = "cd ../..";
  #   };
  #   
  #   oh-my-zsh = {
  #     enable = true;
  #     theme = "robbyrussell";
  #     plugins = [
  #       "git"
  #       "sudo"
  #       "docker"
  #       "kubectl"
  #     ];
  #   };
  #   
  #   initExtra = ''
  #     # Custom zsh configuration
  #   '';
  # };

  # ============================================================================
  # Fish Configuration (Optional)
  # ============================================================================
  # Uncomment to enable Fish shell
  
  # programs.fish = {
  #   enable = true;
  #   
  #   shellAliases = {
  #     ll = "ls -alh";
  #     ".." = "cd ..";
  #     "..." = "cd ../..";
  #   };
  #   
  #   interactiveShellInit = ''
  #     # Custom fish configuration
  #   '';
  # };

  # ============================================================================
  # Starship Prompt (Optional)
  # ============================================================================
  # Cross-shell prompt - works with bash, zsh, fish
  
  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = true;
  #     character = {
  #       success_symbol = "[➜](bold green)";
  #       error_symbol = "[➜](bold red)";
  #     };
  #   };
  # };

  # ============================================================================
  # Directory Navigation
  # ============================================================================
  
  # fzf - fuzzy finder
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # enableZshIntegration = true;  # Uncomment if using zsh
  };

  # zoxide - smarter cd command
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    # enableZshIntegration = true;  # Uncomment if using zsh
  };
}
