{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.collections.base;
in {
  options.${namespace}.home.collections.base.enable = lib.mkEnableOption "baseline home collection";

  config = lib.mkIf cfg.enable {
    programs.home-manager.enable = true;

    ${namespace}.home = {
      security = {
        secrets.enable = lib.mkDefault true;
        onePasswordCLI = {
          enable = lib.mkDefault true;
          environmentSecrets = {
            CEREBRAS_API_KEY = lib.mkDefault "op://Nix/Cerebras/password";
            OPENAI_API_KEY = lib.mkDefault "op://Personal/OpenAI/api_key";
            ANTHROPIC_API_KEY = lib.mkDefault "op://Personal/Anthropic/api_key";
          };
        };
        onePasswordSSH.enable = lib.mkDefault true;
      };

      vcs.git.enable = lib.mkDefault true;

      shells = {
        bash.enable = lib.mkDefault true;
        zsh.enable = lib.mkDefault true;
        nushell.enable = lib.mkDefault true;

        environment = {
          path.enable = lib.mkDefault true;
          direnv.enable = lib.mkDefault true;
        };

        navigation.zoxide.enable = lib.mkDefault true;
        listing.eza.enable = lib.mkDefault true;
        viewers.bat.enable = lib.mkDefault true;
        completions.carapace.enable = lib.mkDefault true;
      };

      prompts.spaceship.enable = lib.mkDefault true;

      cli = {
        gh.enable = lib.mkDefault true;
        ripgrep.enable = lib.mkDefault true;
        fd.enable = lib.mkDefault true;
        jq.enable = lib.mkDefault true;
        fzf.enable = lib.mkDefault true;
        delta.enable = lib.mkDefault true;
        cachix.enable = lib.mkDefault true;
        nixd.enable = lib.mkDefault true;
      };
    };
  };
}
