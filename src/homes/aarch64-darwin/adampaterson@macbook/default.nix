{pkgs, ...}: {
  home.username = "adampaterson";
  home.homeDirectory = "/Users/adampaterson";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  local.onePasswordSSH = {
    enable = true;
    includeBookmarkConfig = true;
    hosts."aurora aurora-1.taileb2c54.ts.net 100.77.42.103 46.225.111.125" = {
      hostName = "46.225.111.125";
      user = "adam";
      identitiesOnly = false;
    };
    hosts."ssh.dev.azure.com" = {
      hostName = "ssh.dev.azure.com";
      user = "git";
      identitiesOnly = true;
      identityFile = "~/.ssh/id_rsa_azure";
    };
  };

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
    installDesktop = true;
  };

  local.codex.enable = true;

  # Neovim configuration
  local.neovim = {
    enable = true;
    enableAI = true;
    enableDAP = false;
    languages = {
      typescript = true;
      python = false;
      go = true;
      rust = true;
      nix = true;
      csharp = true;
    };
  };

  # Enable new CLI tools
  local.git.enable = true;
  local.shell.enable = true;
  local.tailwind.enable = true;

  home.packages = with pkgs; [
    just
  ];
}
