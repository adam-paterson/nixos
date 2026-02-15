{homeDirectory}: let
  stateDir = "${homeDirectory}/.openclaw-adam";
  docsDir = "${stateDir}/workspace";
  trainerDir = "${docsDir}/agents/personal-trainer";
in {
  enable = true;
  gatewayPort = 18789;

  inherit stateDir;
  workspaceDir = docsDir;

  config = {
    agents = {
      list = [
        {
          id = "main";
          default = true;
          name = "Adam";
          agentDir = docsDir;
        }
        {
          id = "personal-trainer";
          name = "Adam Personal Trainer";
          agentDir = trainerDir;
        }
      ];
    };
  };
}
