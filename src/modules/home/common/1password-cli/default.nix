{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.onePasswordCLI;

  # Generate the env file content from the configured secrets
  envFileContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: path: ''${name}="${path}"'') cfg.environmentSecrets
  );

  # Script to load env vars using op run
  loadEnvScript = pkgs.writeShellScriptBin "op-env" ''
    # Check if user is signed in to 1Password
    if ! ${pkgs._1password-cli}/bin/op account list >/dev/null 2>&1; then
      echo "Not signed in to 1Password. Running 'op signin'..."
      eval "$(${pkgs._1password-cli}/bin/op signin)"
    fi

    # Export all env vars from the generated file
    while IFS='=' read -r key value; do
      [[ -z "$key" ]] && continue
      [[ "$key" =~ ^# ]] && continue
      export "$key"="$value"
      echo "Loaded: $key"
    done < ${cfg.envFilePath}

    echo "1Password environment variables loaded!"
  '';
in {
  options.local.onePasswordCLI = {
    enable = lib.mkEnableOption "1Password CLI with automatic environment variable loading";

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bash completions and aliases";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zsh completions and aliases";
    };

    envFilePath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/op/env-vars";
      description = "Path to the generated environment variables file";
    };

    environmentSecrets = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = lib.literalExpression ''
        {
          ANTHROPIC_API_KEY = "op://Personal/Anthropic/credential";
          OPENAI_API_KEY = "op://Personal/OpenAI/credential";
        }
      '';
      description = ''
        Environment variables to load from 1Password.
        Format: VAR_NAME = "op://vault/item/field"
        Run 'op-env' to load them into your shell.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs._1password-cli
      loadEnvScript
    ];

    # Generate the env file from configured secrets
    home.file.${cfg.envFilePath} = lib.mkIf (cfg.environmentSecrets != {}) {
      text = envFileContent;
    };

    # Zsh integration
    programs.zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
      # 1Password CLI completions
      eval "$(${pkgs._1password-cli}/bin/op completion zsh)"

      # Alias to load 1Password environment variables
      alias op-env='eval $(op-env)'
    '';

    # Bash integration
    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      eval "$(${pkgs._1password-cli}/bin/op completion bash)"
      alias op-env='eval $(op-env)'
    '';
  };
}
