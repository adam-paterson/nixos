{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cosmos.prompts.spaceship;
in {
  options.cosmos.prompts.spaceship = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Spaceship prompt for Zsh.";
    };

    addNewline = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Spaceship adds an extra newline before the prompt.";
    };

    separateLine = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Spaceship separates prompt sections onto multiple lines.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = lib.mkDefault true;
      plugins = [
        {
          name = "spaceship-prompt";
          src = pkgs.spaceship-prompt;
          file = "lib/spaceship-prompt/spaceship.zsh";
        }
      ];

      initContent = lib.mkAfter ''
        SPACESHIP_PROMPT_ADD_NEWLINE=${
          if cfg.addNewline
          then "true"
          else "false"
        }
        SPACESHIP_PROMPT_SEPARATE_LINE=${
          if cfg.separateLine
          then "true"
          else "false"
        }

        autoload -U promptinit
        promptinit
        prompt spaceship
      '';
    };
  };
}
