{
  lib,
  pkgs,
  ...
}: {
  home.username = "adam";
  home.homeDirectory = "/home/adam";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  local.onePasswordSSH.enable = false;
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
      config = {
        gateway = {
          mode = "local";
          port = 18789;
          bind = "loopback";
          auth = {
            mode = "token";
            token = "b27f3b80dbedb86512fe5ab0fdb021a268d4bbec6eb35ce2";
          };
        };
      };
    };

    rachel = {
      gatewayPort = 18790;
      config = {
        gateway = {
          mode = "local";
          port = 18790;
          bind = "loopback";
        };

        agents.list = [
          {
            id = "rachel-main";
            default = true;
            agentDir = "/home/adam/.openclaw-rachel/agents/rachel-main";
            identity.name = "Rachel";
          }
          {
            id = "rachel-coder";
            agentDir = "/home/adam/.openclaw-rachel/agents/rachel-coder";
            identity.name = "Rachel Coder";
          }
        ];
      };
    };
  };

  home.file = {
    ".openclaw-adam/openclaw.json".force = true;
    ".openclaw-rachel/openclaw.json".force = true;
    ".openclaw-rachel/agents/rachel-main/AGENTS.md".source = ../../../config/openclaw/agents/rachel-main/AGENTS.md;
    ".openclaw-rachel/agents/rachel-coder/AGENTS.md".source = ../../../config/openclaw/agents/rachel-coder/AGENTS.md;
  };

  home.packages = with pkgs; [
    tmux
  ];
}
