{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.security.onePasswordCLI;

  # Generate the env file content from the configured secrets
  envFileContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: path: ''${name}="${path}"'') cfg.environmentSecrets
  );

  # Script to load env vars — uses op environment read if environmentId is set,
  # otherwise falls back to individual op:// references from envFilePath.
  loadEnvScript = pkgs.writeShellScriptBin "op-env" ''
    # Read OP_SERVICE_ACCOUNT_TOKEN from file if not already set in environment
    if [ -z "$OP_SERVICE_ACCOUNT_TOKEN" ] && [ -n "$OP_SERVICE_ACCOUNT_TOKEN_FILE" ] && [ -f "$OP_SERVICE_ACCOUNT_TOKEN_FILE" ]; then
      export OP_SERVICE_ACCOUNT_TOKEN
      OP_SERVICE_ACCOUNT_TOKEN="$(cat "$OP_SERVICE_ACCOUNT_TOKEN_FILE")"
    fi

    ${
      if cfg.environmentId != null
      then ''
        # 1Password Environments: load all vars from the named environment at once
        eval "$(${pkgs._1password-cli}/bin/op environment read ${cfg.environmentId})"
        echo "1Password environment variables loaded from Environment ${cfg.environmentId}!"
      ''
      else ''
        # Fallback: individual op:// references via generated env-vars file
        if ! ${pkgs._1password-cli}/bin/op account list >/dev/null 2>&1; then
          echo "Not signed in to 1Password. Running 'op signin'..."
          eval "$(${pkgs._1password-cli}/bin/op signin)"
        fi

        while IFS='=' read -r key value; do
          [[ -z "$key" ]] && continue
          [[ "$key" =~ ^# ]] && continue
          export "$key"="$value"
          echo "Loaded: $key"
        done < ${cfg.envFilePath}

        echo "1Password environment variables loaded!"
      ''
    }
  '';
in {
  options.${namespace}.home.security.onePasswordCLI = {
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
      description = "Path to the generated environment variables file (used when environmentId is not set)";
    };

    environmentId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "blgexucrwfr2dtsxe2q4uu7dp4";
      description = ''
        1Password Environment ID to load all variables from at once using
        `op environment read`. When set, the op-env script uses this instead
        of reading individual op:// references from envFilePath.
        Get the ID from: 1Password app > Developer > View Environments > Manage environment > Copy environment ID.
        Requires 1Password CLI >= 2.33.0-beta.02 and OP_SERVICE_ACCOUNT_TOKEN or desktop app auth.
      '';
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
        Environment variables to load from 1Password using individual op:// references.
        Only used when environmentId is not set.
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

    # Generate the env file from configured secrets (only used in fallback path)
    home.file.${cfg.envFilePath} =
      lib.mkIf (cfg.environmentId == null && cfg.environmentSecrets != {})
      {
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
