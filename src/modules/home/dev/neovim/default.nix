# ╭──────────────────────────────────────────────────────────╮
# │ Neovim Configuration Module                              │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cosmos.neovim;
  gotoolsNoPlay = pkgs.gotools.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        rm -f "$out/bin/play"
      '';
  });
in {
  options.cosmos.neovim = {
    enable = mkEnableOption "Neovim configuration";

    enableAI = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GitHub Copilot integration";
    };

    enableDAP = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Debug Adapter Protocol support";
    };

    languages = mkOption {
      type = types.submodule {
        options = {
          typescript =
            mkEnableOption "TypeScript/JavaScript support"
            // {
              default = true;
            };
          python =
            mkEnableOption "Python support"
            // {
              default = true;
            };
          go =
            mkEnableOption "Go support"
            // {
              default = true;
            };
          rust =
            mkEnableOption "Rust support"
            // {
              default = true;
            };
          nix =
            mkEnableOption "Nix support"
            // {
              default = true;
            };
          csharp =
            mkEnableOption "C# support"
            // {
              default = true;
            };
        };
      };
      default = {};
      description = "Enable language-specific tooling";
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = mkDefault true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = false;
    };

    xdg.configFile = {
      "nvim/init.lua".source = ./neovim-config/init.lua;
      "nvim/lua".source = ./neovim-config/lua;
      "nvim/after".source = ./neovim-config/after;
    };

    home.packages = with pkgs; [
      # Core tools
      git
      gcc
      tree-sitter
      ripgrep
      fd
      fzf
      lazygit

      # ╭────────────────────────────────────────────────────╮
      # │ Language Servers                                    │
      # ╰────────────────────────────────────────────────────╯
      # TypeScript/JavaScript
      (mkIf cfg.languages.typescript nodePackages.typescript-language-server)
      (mkIf cfg.languages.typescript nodePackages.vscode-langservers-extracted)
      (mkIf cfg.languages.typescript tailwindcss-language-server)
      (mkIf cfg.languages.typescript emmet-language-server)

      # Python
      (mkIf cfg.languages.python pyright)
      (mkIf cfg.languages.python ruff)

      # Go
      (mkIf cfg.languages.go gopls)
      (mkIf cfg.languages.go gotoolsNoPlay)

      # Rust
      (mkIf cfg.languages.rust rust-analyzer)

      # Nix
      (mkIf cfg.languages.nix nixd)

      # C#
      (mkIf cfg.languages.csharp omnisharp-roslyn)

      # Other useful LSPs
      lua-language-server
      bash-language-server
      yaml-language-server
      marksman
      taplo

      # ╭────────────────────────────────────────────────────╮
      # │ Formatters                                          │
      # ╰────────────────────────────────────────────────────╯
      (mkIf cfg.languages.typescript prettierd)
      (mkIf cfg.languages.python black)
      (mkIf cfg.languages.go gofumpt)
      (mkIf cfg.languages.nix nixfmt)
      stylua
      shfmt

      # ╭────────────────────────────────────────────────────╮
      # │ Linters                                             │
      # ╰────────────────────────────────────────────────────╯
      (mkIf cfg.languages.typescript eslint_d)
      (mkIf cfg.languages.python ruff)
      (mkIf cfg.languages.go golangci-lint)
      (mkIf cfg.languages.rust clippy)
      selene
      shellcheck
      markdownlint-cli2

      # ╭────────────────────────────────────────────────────╮
      # │ Debug Adapters                                      │
      # ╰────────────────────────────────────────────────────╯
      (mkIf cfg.enableDAP vscode-js-debug)
      (mkIf (cfg.enableDAP && cfg.languages.python) python312Packages.debugpy)
      (mkIf (cfg.enableDAP && cfg.languages.go) delve)
      (mkIf (cfg.enableDAP && cfg.languages.csharp) netcoredbg)

      # ╭────────────────────────────────────────────────────╮
      # │ AI Tools                                            │
      # ╰────────────────────────────────────────────────────╯
      (mkIf cfg.enableAI copilot-language-server)
      (mkIf cfg.enableAI github-copilot-cli)
    ];

    # Set environment variables
    home.sessionVariables = {
      EDITOR = mkDefault "nvim";
      VISUAL = mkDefault "nvim";
    };
  };
}
