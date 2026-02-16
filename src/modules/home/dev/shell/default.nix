{
  config,
  lib,
  pkgs,
  ...
}: let
  sharedAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ls = "eza";
    ll = "eza -gl";
    la = "eza -gla";
    lt = "eza -T";
    tail = "tspin";
    gst = "git status -sb";
    glog = "git log --oneline --graph";
    vim = "nvim";
    # Zoxide aliases
    z = "__zoxide_z";
    zi = "__zoxide_zi";
  };
in {
  options.local.shell = {
    enable = lib.mkEnableOption "Shell configuration with Bat, Eza, Zoxide";
  };

  config = lib.mkIf config.local.shell.enable {
    programs = {
      # ╭──────────────────────────────────────────────────────────╮
      # │ Bat - Syntax-highlighting cat clone                       │
      # ╰──────────────────────────────────────────────────────────╯
      bat = {
        enable = true;
        config.theme = "Catppuccin Mocha";
        themes."Catppuccin Mocha" = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
            sha256 = "1y5sfi7jfr97z1g6vm2mzbsw59j1jizwlmbadvmx842m0i5ak5ll";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };

      # ╭──────────────────────────────────────────────────────────╮
      # │ Eza - Modern ls replacement                               │
      # ╰──────────────────────────────────────────────────────────╯
      eza = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = false;
        extraOptions = [
          "--group-directories-first"
          "--octal-permissions"
        ];
        git = true;
        icons = "always";
      };

      # ╭──────────────────────────────────────────────────────────╮
      # │ Zoxide - Frecency-based cd                                │
      # ╰──────────────────────────────────────────────────────────╯
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        options = ["--cmd cd"]; # Replace cd with zoxide
      };

      # ╭──────────────────────────────────────────────────────────╮
      # │ Direnv - Per-directory environments                       │
      # ╰──────────────────────────────────────────────────────────╯
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # ╭──────────────────────────────────────────────────────────╮
      # │ Shell configurations                                      │
      # ╰──────────────────────────────────────────────────────────╯
      bash = {
        enable = lib.mkDefault true;
        enableCompletion = true;
        shellAliases = sharedAliases;
      };

      zsh = {
        enable = lib.mkDefault true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = sharedAliases;
      };

      nushell = {
        enable = true;
        shellAliases = sharedAliases;
        extraConfig = ''
          # Zoxide integration for Nushell
          source ${pkgs.zoxide}/share/zoxide/init.nu
        '';
      };
    };

    # Prepend nix-profile/bin to PATH before system paths
    home.sessionPath = [
      "$HOME/.nix-profile/bin"
    ];

    home.sessionVariables = {
      TERM = "xterm-ghostty";
      EDITOR = "nvim";
      GIT_EDITOR = "nvim";
    };
  };
}
