{pkgs, ...}: {
  imports = [
    ../../common
  ];

  home = {
    username = "adam";
    homeDirectory = "/home/adam";
    stateVersion = "26.05";
  };

  local.onePasswordSSH.enable = true;

  local.neovim.enableDAP = true;

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
