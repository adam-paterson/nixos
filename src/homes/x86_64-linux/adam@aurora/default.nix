{
  config,
  lib,
  pkgs,
  ...
}: let
  mergeAttrs = lib.foldl' lib.recursiveUpdate {};
  repoAgentsRoot = "/home/adam/projects/personal/nixos/src/config/openclaw/agents";
  managedAgentFiles = {
    main = ["AGENTS.md"];
    "personal-trainer" = [
      "AGENTS.md"
      "SOUL.md"
      "TOOLS.md"
      "IDENTITY.md"
      "USER.md"
    ];
  };
  instanceNames = [
    "adam"
    "rachel"
  ];
  syncPairs =
    lib.concatMapStringsSep "\n" (
      instanceName:
        lib.concatMapStringsSep "\n" (
          agentId: let
            repoDir = "${repoAgentsRoot}/${instanceName}/${agentId}";
            workspaceDir = "/home/adam/.openclaw-${instanceName}/workspace/agents/${agentId}";
          in
            lib.concatMapStringsSep "\n" (fileName: "${repoDir}/${fileName}\t${workspaceDir}/${fileName}") managedAgentFiles.${agentId}
        ) (lib.attrNames managedAgentFiles)
    )
    instanceNames;
  agentSyncScript = pkgs.writeShellScriptBin "openclaw-agent-sync" ''
    set -euo pipefail

    mode="''${1:-sync-bidirectional}"

    copy_if_missing() {
      src="$1"
      dst="$2"
      [ -f "$src" ] || return 0
      mkdir -p "$(dirname "$dst")"
      [ -f "$dst" ] || cp "$src" "$dst"
    }

    copy_if_changed() {
      src="$1"
      dst="$2"
      [ -f "$src" ] || return 0
      mkdir -p "$(dirname "$dst")"
      if [ ! -f "$dst" ] || ! cmp -s "$src" "$dst"; then
        cp "$src" "$dst"
      fi
    }

    sync_bidirectional() {
      repoFile="$1"
      workspaceFile="$2"
      repoExists=0
      wsExists=0
      [ -f "$repoFile" ] && repoExists=1
      [ -f "$workspaceFile" ] && wsExists=1

      if [ "$repoExists" -eq 1 ] && [ "$wsExists" -eq 0 ]; then
        mkdir -p "$(dirname "$workspaceFile")"
        cp "$repoFile" "$workspaceFile"
        return 0
      fi
      if [ "$repoExists" -eq 0 ] && [ "$wsExists" -eq 1 ]; then
        mkdir -p "$(dirname "$repoFile")"
        cp "$workspaceFile" "$repoFile"
        return 0
      fi
      if [ "$repoExists" -eq 1 ] && [ "$wsExists" -eq 1 ]; then
        if [ "$workspaceFile" -nt "$repoFile" ]; then
          cp "$workspaceFile" "$repoFile"
        elif [ "$repoFile" -nt "$workspaceFile" ]; then
          cp "$repoFile" "$workspaceFile"
        fi
      fi
    }

    while IFS=$'\t' read -r repoFile workspaceFile; do
      [ -n "$repoFile" ] || continue
      case "$mode" in
        sync-to-workspaces)
          copy_if_missing "$repoFile" "$workspaceFile"
          ;;
        sync-to-repo)
          copy_if_changed "$workspaceFile" "$repoFile"
          ;;
        sync-bidirectional)
          sync_bidirectional "$repoFile" "$workspaceFile"
          ;;
        *)
          echo "Usage: openclaw-agent-sync [sync-to-workspaces|sync-to-repo|sync-bidirectional]" >&2
          exit 2
          ;;
      esac
    done <<'PAIRS'
    ${syncPairs}
    PAIRS
  '';

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
        OPENAI_API_KEY = "{env:OPENAI_API_KEY}";
        ANTHROPIC_API_KEY = "{env:ANTHROPIC_API_KEY}";
      };
    };
    auth = {
      profiles = {
        "cerebras:default" = {
          provider = "cerebras";
          mode = "api_key";
        };
        "openai:default" = {
          provider = "openai";
          mode = "api_key";
        };
        "anthropic:default" = {
          provider = "anthropic";
          mode = "api_key";
        };
      };
    };
    models = {
      mode = "merge";
      providers = {};
    };
    plugins.entries.whatsapp.enabled = true;
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
    # Placeholder 1Password item references.
    # Replace these with your real op://vault/item/field paths.
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

  programs.openclaw.instances = {
    adam = {
      gatewayPort = 18789;
      config = mergeAttrs [
        sharedOpenclawConfig
        {
          gateway.port = 18789;
          agents.defaults.workspace = "/home/adam/.openclaw-adam/workspace";

          channels.whatsapp = {
            dmPolicy = "allowlist";
            allowFrom = ["+447595944315"];
            groups = {
              "*" = {requireMention = true;};
            };
            sendReadReceipts = true;
          };

          agents.list = [
            {
              id = "main";
              default = true;
              agentDir = "/home/adam/.openclaw-adam/workspace/agents/main";
              identity.name = "adam";
            }
            {
              id = "personal-trainer";
              agentDir = "/home/adam/.openclaw-adam/agents/personal-trainer";
              workspace = "/home/adam/.openclaw-adam/workspace/agents/personal-trainer";
              identity.name = "Personal Trainer";
            }
          ];
        }
      ];
    };

    rachel = {
      gatewayPort = 18810;
      config = mergeAttrs [
        sharedOpenclawConfig
        {
          gateway.port = 18810;
          agents = {
            defaults.workspace = "/home/adam/.openclaw-rachel/workspace";
            defaults.skipBootstrap = true;
          };

          channels.whatsapp = {
            dmPolicy = "allowlist";
            allowFrom = [
              "+447595944315"
              "+447432133399"
            ];
            groups = {
              "*" = {requireMention = true;};
            };
            sendReadReceipts = true;
          };

          agents.list = [
            {
              id = "main";
              default = false;
              agentDir = "/home/adam/.openclaw-rachel/workspace/agents/main";
              identity.name = "rachel";
            }
            {
              id = "personal-trainer";
              default = true;
              agentDir = "/home/adam/.openclaw-rachel/agents/personal-trainer";
              workspace = "/home/adam/.openclaw-rachel/workspace/agents/personal-trainer";
              identity.name = "Personal Trainer";
            }
          ];
        }
      ];
    };
  };

  home.file = {
    ".openclaw-adam/openclaw.json".force = true;
    ".openclaw-rachel/openclaw.json".force = true;
    ".config/openclaw/secrets.env.example".text = ''
      # Copy to ~/.config/openclaw/secrets.env and keep it out of git.
      # Used by the OpenClaw systemd user services on Linux.
      # Required for 1Password service-account auth in systemd:
      OP_SERVICE_ACCOUNT_TOKEN=replace-with-real-token
      # Optional fallback values if you are not using 1Password runtime injection:
      CEREBRAS_API_KEY=replace-with-real-key
      OPENAI_API_KEY=replace-with-real-key
      ANTHROPIC_API_KEY=replace-with-real-key
    '';
  };

  home.packages = with pkgs; [
    tmux
    agentSyncScript
  ];

  home.activation.openclawAgentWorkspaceSeed = lib.hm.dag.entryAfter ["openclawDirs"] ''
    run --quiet ${agentSyncScript}/bin/openclaw-agent-sync sync-to-workspaces
  '';

  programs.bash.initExtra = lib.mkAfter ''
    # Load OP service-account token for CLI usage from local, non-Nix-tracked secrets.
    if [ -f "$HOME/.config/openclaw/secrets.env" ]; then
      op_token="$(sed -n 's/^OP_SERVICE_ACCOUNT_TOKEN=//p' "$HOME/.config/openclaw/secrets.env" | head -n1)"
      op_token="''${op_token#\"}"
      op_token="''${op_token%\"}"
      if [ -n "$op_token" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN="$op_token"
      fi
      unset op_token
    fi
  '';

  programs.zsh.initContent = lib.mkAfter ''
    # Load OP service-account token for CLI usage from local, non-Nix-tracked secrets.
    if [ -f "$HOME/.config/openclaw/secrets.env" ]; then
      op_token="$(sed -n 's/^OP_SERVICE_ACCOUNT_TOKEN=//p' "$HOME/.config/openclaw/secrets.env" | head -n1)"
      op_token="''${op_token#\"}"
      op_token="''${op_token%\"}"
      if [ -n "$op_token" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN="$op_token"
      fi
      unset op_token
    fi
  '';

  systemd.user.services = {
    "openclaw-gateway-adam" = {
      Install.WantedBy = ["default.target"];
      # Optional file: keep gateway booting even before secrets are provisioned.
      Service.EnvironmentFile = ["-%h/.config/openclaw/secrets.env"];
      Service.ExecStart = lib.mkForce ''
        ${pkgs.bash}/bin/bash -lc 'tok="''${OP_SERVICE_ACCOUNT_TOKEN:-}"; tok="$(echo "$tok" | sed -e "s/^\"//" -e "s/\"$//")"; if [ -n "$tok" ] && [ -f "$HOME/.config/op/env-vars" ]; then OP_SERVICE_ACCOUNT_TOKEN="$tok" ${pkgs._1password-cli}/bin/op run --env-file "$HOME/.config/op/env-vars" -- ${config.programs.openclaw.package}/bin/openclaw gateway --port 18789 || echo "[openclaw] op run failed for adam, falling back to direct env" >&2; fi; exec ${config.programs.openclaw.package}/bin/openclaw gateway --port 18789'
      '';
    };

    "openclaw-gateway-rachel" = {
      Install.WantedBy = ["default.target"];
      # Optional file: keep gateway booting even before secrets are provisioned.
      Service.EnvironmentFile = ["-%h/.config/openclaw/secrets.env"];
      Service.ExecStart = lib.mkForce ''
        ${pkgs.bash}/bin/bash -lc 'tok="''${OP_SERVICE_ACCOUNT_TOKEN:-}"; tok="$(echo "$tok" | sed -e "s/^\"//" -e "s/\"$//")"; if [ -n "$tok" ] && [ -f "$HOME/.config/op/env-vars" ]; then OP_SERVICE_ACCOUNT_TOKEN="$tok" ${pkgs._1password-cli}/bin/op run --env-file "$HOME/.config/op/env-vars" -- ${config.programs.openclaw.package}/bin/openclaw gateway --port 18810 || echo "[openclaw] op run failed for rachel, falling back to direct env" >&2; fi; exec ${config.programs.openclaw.package}/bin/openclaw gateway --port 18810'
      '';
    };
  };
}
