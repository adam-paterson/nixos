{pkgs, ...}: {
  home = {
    username = "adam";
    homeDirectory = "/home/adam";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  local.onePasswordSSH.enable = true;

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
    installDesktop = false;
  };

  local.codex.enable = true;

  local.git.enable = true;
  local.shell.enable = true;
  local.tailwind.enable = true;

  local.neovim = {
    enable = true;
    enableAI = true;
    enableDAP = true;
    languages = {
      typescript = true;
      python = false;
      go = true;
      rust = true;
      nix = true;
      csharp = false;
    };
  };

  home.packages = with pkgs; [
    tmux
  ];

  programs.openclaw.instances = {
    adam = {
      gatewayPort = 18789;
      workspaceDir = "/home/adam/.openclaw-adam/workspace";
      config = {
        gateway.port = 18789;
        agents.list = [
          {
            id = "main";
            default = true;
            agentDir = "/home/adam/.openclaw-adam/workspace/agents/main";
            identity.name = "adam";
          }
        ];
      };
    };

    rachel = {
      gatewayPort = 18810;
      workspaceDir = "/home/adam/.openclaw-rachel/workspace";
      config = {
        gateway.port = 18810;
        agents.list = [
          {
            id = "main";
            default = true;
            agentDir = "/home/adam/.openclaw-rachel/workspace/agents/main";
            identity.name = "rachel";
          }
        ];
      };
    };
  };
}
