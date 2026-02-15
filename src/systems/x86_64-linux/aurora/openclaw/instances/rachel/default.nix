{homeDirectory}: let
  stateDir = "${homeDirectory}/.openclaw-rachel";
  docsDir = "${stateDir}/workspace";
  trainerDir = "${docsDir}/agents/personal-trainer";
in {
  enable = true;
  gatewayPort = 18810;

  inherit stateDir;
  workspaceDir = docsDir;

  config = {
    agents = {
      list = [
        {
          id = "main";
          default = true;
          name = "Rachel";
          agentDir = docsDir;
        }
        {
          id = "personal-trainer";
          name = "Rachel Personal Trainer";
          agentDir = trainerDir;
        }
      ];
    };
  };
}
