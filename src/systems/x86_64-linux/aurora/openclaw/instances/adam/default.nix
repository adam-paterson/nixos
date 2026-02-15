let
  docsDir = toString ../config/documents;
  trainerDir = toString ../config/agents/adam/personal-trainer;
in {
  enable = true;
  gatewayPort = 18789;

  stateDir = "/home/adam/.openclaw-adam";
  workspaceDir = "/home/adam/.openclaw-adam/workspace";

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
