{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.base;
in {
  options.local.collections.home.base.enable = lib.mkEnableOption "baseline home collection";

  config = lib.mkIf cfg.enable {
    programs.home-manager.enable = true;

    local = {
      git.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
      onePasswordCLI = {
        enable = lib.mkDefault true;
        environmentSecrets = {
          CEREBRAS_API_KEY = "op://Nix/Cerebras/password";
          OPENAI_API_KEY = "op://Personal/OpenAI/api_key";
          ANTHROPIC_API_KEY = "op://Personal/Anthropic/api_key";
        };
      };
      onePasswordSSH.enable = lib.mkDefault true;
      prompts.spaceship.enable = lib.mkDefault true;
    };
  };
}
