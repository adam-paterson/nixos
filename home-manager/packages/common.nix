# Common Packages
# Installed for all users across all hosts
# See: .agents/skills/nixos-best-practices/rules/package-installation.md

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ============================================================================
    # CLI Utilities
    # ============================================================================
    
    # File management
    tree            # Display directory tree
    fd              # Modern find replacement
    eza             # Modern ls replacement
    
    # Text processing
    ripgrep         # Fast grep alternative (rg)
    jq              # JSON processor
    yq              # YAML processor
    
    # System monitoring
    htop            # Interactive process viewer
    btop            # Resource monitor
    
    # Network tools
    wget            # Download files
    curl            # Transfer data
    
    # Archive tools
    unzip           # Extract ZIP archives
    zip             # Create ZIP archives
    
    # ============================================================================
    # Development Tools
    # ============================================================================
    
    # Version control
    git             # Already configured in programs/git.nix
    gh              # GitHub CLI
    
    # Text editors
    vim             # Terminal text editor
    
    # Build tools
    gnumake         # Make build system
    
    # ============================================================================
    # Productivity
    # ============================================================================
    
    # Terminal multiplexer
    tmux            # Terminal multiplexer
    
    # File transfer
    rsync           # File synchronization
    
    # ============================================================================
    # Optional: Uncomment sections as needed
    # ============================================================================
    
    # Programming languages (uncomment as needed)
    # nodejs          # JavaScript runtime
    # python3         # Python interpreter
    # go              # Go compiler
    # rustc           # Rust compiler
    # cargo           # Rust package manager
    
    # Container tools (uncomment as needed)
    # docker-compose  # Docker Compose
    # kubectl         # Kubernetes CLI
    
    # Cloud tools (uncomment as needed)
    # awscli2         # AWS CLI
    # google-cloud-sdk  # Google Cloud SDK
    # terraform       # Infrastructure as Code
  ];
}
