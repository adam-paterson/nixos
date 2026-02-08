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

  programs.openclaw.instances = {
    adam = {
      gatewayPort = 18789;
      config = mergeAttrs [
        sharedOpenclawConfig
        {
          gateway.port = 18789;
        }
      ];
    };

    rachel = {
      gatewayPort = 18790;
      config = mergeAttrs [
        sharedOpenclawConfig
        {
          gateway.port = 18790;

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
              agentDir = "/home/adam/.openclaw-rachel/agents/main";
              identity.name = "Rachel";
            }
            {
              id = "tammy";
              agentDir = "/home/adam/.openclaw-rachel/agents/tammy";
              identity.name = "Tammy";
              identity.emoji = "🐾";
            }
          ];
        }
      ];
    };
  };

  home.file = {
    ".openclaw-adam/openclaw.json".force = true;
    ".openclaw-rachel/openclaw.json".force = true;
    ".openclaw-rachel/agents/main/AGENTS.md".source = ../../../config/openclaw/agents/rachel/main/AGENTS.md;
    ".openclaw-rachel/agents/tammy/AGENTS.md".source = ../../../config/openclaw/agents/rachel/tammy/AGENTS.md;
  };

  home.packages = with pkgs; [
    tmux
  ];

  systemd.user.services.openclaw-gateway-adam = {
    Install.WantedBy = ["default.target"];
  };
  systemd.user.services.openclaw-gateway-rachel = {
    Install.WantedBy = ["default.target"];
  };
}
