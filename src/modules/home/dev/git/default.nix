{
  config,
  lib,
  pkgs,
  ...
}: let
  catppuccin-delta = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "delta";
    rev = "7b06b1f174c03f53ff68da1ae1666ca3ef7683ad";
    sha256 = "1qkqchyj4dn0w4wq5xhc86dpj0vlmn94n814nzzif8y7rj3g8w0w";
  };
in {
  options.local.git = {
    enable = lib.mkEnableOption "Git configuration with Delta";
  };

  config = lib.mkIf config.local.git.enable {
    programs.git = {
      enable = true;

      includes = [
        {path = "${catppuccin-delta}/catppuccin.gitconfig";}
      ];

      settings = lib.mkMerge [
        {
          user = {
            name = "Adam Paterson";
            email = "hello@adampaterson.co.uk";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1CJVWAx5tlEl1onIshZURohd68JMza5uk1E+eStOUn";
          };

          # Core settings
          core = {
            editor = "nvim";
            longpaths = true;
          };

          # Color
          color.ui = true;

          # Pull behavior
          pull.rebase = true;

          # Merge settings
          merge = {
            autoStash = true;
            conflictstyle = "zdiff3";
          };

          # Rebase settings
          rebase.autoStash = true;

          # Push behavior
          push.autoSetupRemote = true;

          # Default branch
          init.defaultBranch = "main";

          # Useful aliases
          alias = {
            count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += \$1; subs += \$2; loc += \$1 - \$2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
            lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            st = "status -sb";
            co = "checkout";
            br = "branch";
            ci = "commit";
            unstage = "reset HEAD --";
            last = "log -1 HEAD";
          };
        }
        (lib.mkIf pkgs.stdenv.isDarwin {
          gpg.format = "ssh";
          gpg.ssh.program = "${config.home.homeDirectory}/.local/bin/op-ssh-sign";
        })
      ];
    };

    # Delta diff viewer with Catppuccin theme
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        features = "catppuccin-mocha";
        line-numbers = true;
        navigate = true;
        side-by-side = true;
        hyperlinks = true;
      };
    };
  };
}
