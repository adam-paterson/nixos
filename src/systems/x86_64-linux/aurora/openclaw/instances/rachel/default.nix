let
  docsDir = toString ../config/documents;
  trainerDir = toString ../config/agents/rachel/personal-trainer;
in {
  enable = true;
  gatewayPort = 18810;

  stateDir = "/home/adam/.openclaw-rachel";
  workspaceDir = "/home/adam/.openclaw-rachel/workspace";

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
