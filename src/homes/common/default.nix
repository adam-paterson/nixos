{lib, ...}: {
  programs.home-manager.enable = true;

  local.onePasswordCLI = {
    enable = true;
    environmentSecrets = {
      CEREBRAS_API_KEY = "op://Nix/Cerebras/password";
      OPENAI_API_KEY = "op://Personal/OpenAI/api_key";
      ANTHROPIC_API_KEY = "op://Personal/Anthropic/api_key";
    };
  };

  local.opencode = {
    enable = true;
    installDesktop = lib.mkDefault false;
  };

  local.codex.enable = true;

  # Neovim configuration
  local.neovim = {
    enable = true;
    enableAI = true;
    enableDAP = lib.mkDefault false;
    languages = {
      typescript = true;
      python = false;
      go = true;
      rust = true;
      nix = true;
      csharp = lib.mkDefault false;
    };
  };

  # Enable new CLI tools
  local.git.enable = true;
  local.shell.enable = true;
  local.tailwind.enable = true;
}
