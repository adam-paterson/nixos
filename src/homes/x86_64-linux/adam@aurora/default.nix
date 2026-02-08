{
  lib,
  pkgs,
  ...
}: let
  mergeAttrs = lib.foldl' lib.recursiveUpdate {};

  # Shared OpenClaw settings reused by multiple instances.
  # Add common env/model/provider settings here once.
  sharedOpenclawConfig = {
    env = {
      shellEnv = {
        enabled = true;
        timeoutMs = 6000;
      };
      vars = {
        CEREBRAS_API_KEY = "{env:CEREBRAS_API_KEY}";
      };
    };
    auth = {
      profiles = {
        "cerebras:default" = {
          provider = "cerebras";
          mode = "api_key";
        };
      };
    };
    models = {
      mode = "merge";
      providers = {};
    };
    agents.defaults = {
      model.primary = "cerebras/zai-glm-4.7";
      models."cerebras/zai-glm-4.7" = {
        alias = "Cerebras - ZAI GLM 4.7";
        params = {};
      };
    };
    browser = {
      enabled = true;
      evaluateEnabled = true;
      headless = true;
    };
    gateway = {
      mode = "local";
      bind = "loopback";
      auth = {
        mode = "token";
        token = "b27f3b80dbedb86512fe5ab0fdb021a268d4bbec6eb35ce2";
      };
    };
  };
in {
  home.username = "adam";
  home.homeDirectory = "/home/adam";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  local.onePasswordSSH.enable = true;

  local.onePasswordCLI = {
    enable = true;
    # Uncomment and configure with your actual secrets:
    # environmentSecrets = {
    #   ANTHROPIC_API_KEY = "op://Personal/Anthropic/credential";
    #   OPENAI_API_KEY = "op://Personal/OpenAI/credential";
    # };
  };

  local.opencode = {
    enable = true;
    installDesktop = false;
  };

  local.openclaw = {
    enable = true;
    installApp = false;
    manageConfig = false;
  };

  local.codex.enable = true;

  # Neovim configuration
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

  programs.openclaw.instances.default = {
    gatewayPort = 18789;
    config = mergeAttrs [
      sharedOpenclawConfig
      {
        gateway.port = 18789;

        channels.whatsapp = {
          dmPolicy = "allowlist";
          allowFrom = ["+447432133399"];
          groups = {
            "*" = {requireMention = true;};
          };
          sendReadReceipts = true;
        };

        agents.list = [
          {
            id = "main";
            default = true;
            agentDir = "/home/adam/.openclaw/agents/main";
            identity.name = "Rachel";
          }
          {
            id = "tammy";
            agentDir = "/home/adam/.openclaw/agents/tammy";
            identity.name = "Tammy";
            identity.emoji = "🐾";
          }
        ];
      }
    ];
  };

  home.file = {
    ".openclaw/openclaw.json".force = true;
    ".openclaw/agents/main/AGENTS.md".source = ../../../config/openclaw/agents/rachel/main/AGENTS.md;
    ".openclaw/agents/tammy/AGENTS.md".source = ../../../config/openclaw/agents/rachel/tammy/AGENTS.md;
    "/home/adam/.config/systemd/user/default.target.wants/openclaw-gateway.service".force = lib.mkForce true;
    ".config/openclaw/secrets.env.example".text = ''
      # Copy to ~/.config/openclaw/secrets.env and keep it out of git.
      # Used by the OpenClaw systemd user services on Linux.
      CEREBRAS_API_KEY=replace-with-real-key
    '';
  };

  home.packages = with pkgs; [
    tmux
  ];

  systemd.user.services.openclaw-gateway = {
    Install.WantedBy = ["default.target"];
    # Optional file: keep gateway booting even before secrets are provisioned.
    Service.EnvironmentFile = ["-%h/.config/openclaw/secrets.env"];
  };
}
