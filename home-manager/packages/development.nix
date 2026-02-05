# Development Packages
# Optional development tools - import this in home.nix if needed

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ============================================================================
    # Programming Languages
    # ============================================================================
    
    nodejs          # JavaScript/TypeScript runtime
    python3         # Python interpreter
    python3Packages.pip  # Python package manager
    
    # ============================================================================
    # Development Tools
    # ============================================================================
    
    # Language servers (for IDE support)
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    python3Packages.python-lsp-server
    
    # Formatters and linters
    nodePackages.prettier
    nodePackages.eslint
    black           # Python formatter
    ruff            # Python linter
    
    # Build tools
    cmake
    pkg-config
    
    # ============================================================================
    # Container & DevOps
    # ============================================================================
    
    docker-compose
    kubectl
    helm
    
    # ============================================================================
    # Database Tools
    # ============================================================================
    
    # postgresql
    # sqlite
    # redis
  ];
}
