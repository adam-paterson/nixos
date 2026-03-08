_: {
  programs.openclaw = {
    installApp = false;
    config = {
      # ──[ Environment ]──────────────────────────────────────────────────────
      # env.vars (API keys) are managed at runtime by openclaw and not stored here.
      env = {
        shellEnv = {
          enabled = true;
          timeoutMs = 3000;
        };
      };

      # ──[ Update ]───────────────────────────────────────────────────────────
      update = {
        channel = "dev";
        checkOnStart = true;
      };

      # ──[ Browser ]──────────────────────────────────────────────────────────
      browser = {
        enabled = true;
        headless = true;
        noSandbox = true;
        attachOnly = true;
        defaultProfile = "openclaw";
        profiles = {
          openclaw = {
            cdpPort = 18800;
            color = "#FF4500";
          };
        };
      };

      # ──[ Models ]───────────────────────────────────────────────────────────
      models = {
        mode = "merge";
        providers = {
          "fireworks-ai" = {
            baseUrl = "https://api.fireworks.ai/inference/v1/";
            # apiKey is managed at runtime by openclaw
            api = "openai-completions";
            models = [
              {
                id = "accounts/fireworks/models/minimax-m2p5";
                name = "Minimax 2.5 (Fireworks)";
                reasoning = true;
                input = ["text"];
                cost = {
                  input = 0;
                  output = 0;
                  cacheRead = 0;
                  cacheWrite = 0;
                };
                contextWindow = 196600;
                maxTokens = 16384;
              }
              {
                id = "accounts/fireworks/models/glm-5";
                name = "GLM-5 (Fireworks)";
                reasoning = true;
                input = ["text"];
                cost = {
                  input = 0;
                  output = 0;
                  cacheRead = 0;
                  cacheWrite = 0;
                };
                contextWindow = 202800;
                maxTokens = 16384;
              }
              {
                id = "accounts/fireworks/models/qwen3-8b";
                name = "Qwen 3 - 8B (Fireworks)";
                reasoning = false;
                input = ["text"];
                cost = {
                  input = 0;
                  output = 0;
                  cacheRead = 0;
                  cacheWrite = 0;
                };
                contextWindow = 41000;
                maxTokens = 8192;
                compat = {
                  thinkingFormat = "qwen";
                };
              }
            ];
          };
        };
      };

      # ──[ Agents ]───────────────────────────────────────────────────────────
      agents = {
        defaults = {
          model = {
            primary = "fireworks-ai/accounts/fireworks/models/glm-5";
          };
          models = {
            "fireworks-ai/accounts/fireworks/models/minimax-m2p5" = {
              alias = "fw-minimax-2.5";
            };
            "fireworks-ai/accounts/fireworks/models/glm-5" = {
              alias = "fw-glm-5";
            };
            "fireworks-ai/accounts/fireworks/models/qwen3-8b" = {
              alias = "fw-qwen3-8b";
            };
          };
          workspace = "/home/adam/.openclaw/workspace";
          contextTokens = 200000;
          memorySearch = {
            enabled = true;
            experimental = {
              sessionMemory = true;
            };
            cache = {
              enabled = true;
            };
          };
          compaction = {
            mode = "safeguard";
          };
          typingMode = "instant";
          heartbeat = {
            every = "30m";
            model = "fireworks-ai/accounts/fireworks/models/qwen3-8b";
            target = "last";
          };
          subagents = {
            model = "fireworks-ai/accounts/fireworks/models/minimax-m2p5";
          };
        };
        list = [
          {
            id = "adam-main";
            default = false;
            name = "Adam Main";
            workspace = "/home/adam/.openclaw/workspace-adam";
            identity = {
              name = "Astra";
              emoji = "✨";
            };
            subagents = {
              allowAgents = [
                "thrive-assistant"
                "software-engineer"
              ];
            };
          }
          {
            id = "rachel-main";
            default = false;
            name = "Rachel Main";
            workspace = "/home/adam/.openclaw/workspace-rachel";
            model = {
              primary = "fireworks-ai/accounts/fireworks/models/minimax-m2p5";
            };
            identity = {
              name = "Tammy";
              emoji = "🐾";
            };
            subagents = {
              allowAgents = [];
            };
          }
          {
            id = "thrive-assistant";
            default = false;
            name = "Thrive Assistant";
            workspace = "/home/adam/.openclaw/workspace-thrive-assistant";
            model = {
              primary = "fireworks-ai/accounts/fireworks/models/minimax-m2p5";
            };
            identity = {
              name = "Thrive";
              emoji = "🚀";
            };
          }
          {
            id = "software-engineer";
            default = false;
            name = "Software Engineer";
            workspace = "/home/adam/.openclaw/workspace-software-engineer";
            model = {
              primary = "fireworks-ai/accounts/fireworks/models/glm-5";
            };
            identity = {
              name = "Coder";
              emoji = "💻";
            };
            subagents = {
              allowAgents = [];
            };
            tools = {
              profile = "full";
            };
          }
          {
            id = "swarm-orchestrator";
            default = false;
            name = "Swarm Orchestrator";
            workspace = "/home/adam/.openclaw/workspace-swarm-orchestrator";
            model = {
              primary = "fireworks-ai/accounts/fireworks/models/glm-5";
            };
            identity = {
              name = "Zoe";
              emoji = "🧭";
            };
            subagents = {
              allowAgents = [];
            };
            tools = {
              profile = "full";
            };
          }
        ];
      };

      # ──[ Tools ]────────────────────────────────────────────────────────────
      tools = {
        web = {
          search = {
            enabled = false;
          };
          fetch = {
            enabled = true;
          };
        };
        agentToAgent = {
          enabled = true;
        };
      };

      # ──[ Bindings ]─────────────────────────────────────────────────────────
      bindings = [
        {
          agentId = "adam-main";
          match = {
            channel = "whatsapp";
            accountId = "adam";
            peer = {
              kind = "direct";
              id = "+447595944315";
            };
          };
        }
        {
          agentId = "rachel-main";
          match = {
            channel = "whatsapp";
            accountId = "rachel";
            peer = {
              kind = "direct";
              id = "+447432133399";
            };
          };
        }
        {
          agentId = "rachel-main";
          match = {
            channel = "whatsapp";
            accountId = "rachel";
            peer = {
              kind = "direct";
              id = "+447595944315";
            };
          };
        }
      ];

      # ──[ Messages ]─────────────────────────────────────────────────────────
      messages = {
        ackReaction = "👍🏻";
      };

      # ──[ Commands ]─────────────────────────────────────────────────────────
      commands = {
        native = "auto";
        nativeSkills = "auto";
        restart = true;
        ownerDisplay = "raw";
      };

      # ──[ Hooks ]────────────────────────────────────────────────────────────
      hooks = {
        enabled = true;
        path = "/hooks";
        # token is managed at runtime by openclaw
        allowedAgentIds = ["adam-main"];
        mappings = [
          {
            match = {
              path = "linear";
            };
            action = "agent";
            agentId = "adam-main";
            messageTemplate = "Linear webhook received: {{payload.action.type}} on {{payload.data.issue.identifier}} - {{payload.data.issue.title}}";
          }
        ];
        internal = {
          enabled = true;
        };
      };

      # ──[ Channels ]─────────────────────────────────────────────────────────
      channels = {
        whatsapp = {
          enabled = true;
          dmPolicy = "pairing";
          selfChatMode = false;
          groupPolicy = "allowlist";
          ackReaction = {
            emoji = "👍🏻";
            direct = false;
            group = "mentions";
          };
          debounceMs = 0;
          accounts = {
            adam = {
              enabled = true;
              configWrites = true;
              dmPolicy = "allowlist";
              allowFrom = ["+447595944315"];
              groupPolicy = "disabled";
              historyLimit = 5;
              dms = {};
              ackReaction = {
                emoji = "👍🏻";
                direct = true;
                group = "mentions";
              };
              debounceMs = 0;
            };
            rachel = {
              enabled = true;
              configWrites = true;
              dmPolicy = "allowlist";
              allowFrom = [
                "+447432133399"
                "+447595944315"
              ];
              groupPolicy = "disabled";
              historyLimit = 5;
              dms = {};
              ackReaction = {
                emoji = "👍🏻";
                direct = true;
                group = "mentions";
              };
              debounceMs = 0;
              name = "Rachel";
            };
            default = {
              dmPolicy = "allowlist";
              allowFrom = ["+447595944315"];
              groupPolicy = "allowlist";
              debounceMs = 0;
            };
          };
          mediaMaxMb = 50;
          actions = {
            reactions = true;
            sendMessage = true;
            polls = true;
          };
        };
      };

      # ──[ Canvas Host ]──────────────────────────────────────────────────────
      canvasHost = {
        enabled = true;
        liveReload = true;
      };

      # ──[ Gateway ]──────────────────────────────────────────────────────────
      gateway = {
        port = 18666;
        mode = "local";
        bind = "lan";
        controlUi = {
          allowedOrigins = [
            "http://localhost:18666"
            "http://127.0.0.1:18666"
            "https://oc.adampaterson.co.uk"
          ];
          allowInsecureAuth = true;
        };
        auth = {
          mode = "token";
          # token is managed via OPENCLAW_GATEWAY_AUTH_TOKEN_FILE at runtime (see security/secrets)
          allowTailscale = true;
        };
        tailscale = {
          mode = "off";
          resetOnExit = false;
        };
      };

      # ──[ Memory ]───────────────────────────────────────────────────────────
      memory = {
        backend = "builtin";
        citations = "auto";
      };

      # ──[ Skills ]───────────────────────────────────────────────────────────
      skills = {
        install = {
          nodeManager = "bun";
        };
        entries = {
          "linear-tasks" = {
            enabled = true;
          };
          "codex-orchestration" = {
            enabled = true;
          };
          "software-engineer" = {
            enabled = true;
          };
        };
      };

      # ──[ Plugins ]──────────────────────────────────────────────────────────
      plugins = {
        entries = {
          whatsapp = {
            enabled = true;
          };
        };
      };
    };
  };
}
