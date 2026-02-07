{pkgs, ...}: {
  home.username = "adampaterson";
  home.homeDirectory = "/Users/adampaterson";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  local.onePasswordSSH = {
    enable = true;
    includeBookmarkConfig = true;
    hosts."aurora aurora-1.taileb2c54.ts.net 100.77.42.103 46.225.111.125" = {
      hostName = "46.225.111.125";
      user = "adam";
      identitiesOnly = false;
    };
  };

  local.opencode = {
    enable = true;
    installDesktop = true;
  };

  local.openclaw = {
    enable = false;
    installApp = true;
  };

  home.packages = with pkgs; [
    just
  ];
}
