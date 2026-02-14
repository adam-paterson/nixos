{pkgs, ...}: {
  imports = [
    ../../common
  ];

  home = {
    username = "adampaterson";
    homeDirectory = "/Users/adampaterson";
    stateVersion = "26.05";
  };

  local = {
    onePasswordSSH = {
      enable = true;
      includeBookmarkConfig = true;
      hosts."aurora aurora-1.taileb2c54.ts.net 100.77.42.103 46.225.111.125" = {
        hostName = "46.225.111.125";
        user = "adam";
        identitiesOnly = false;
      };
      hosts."ssh.dev.azure.com" = {
        hostName = "ssh.dev.azure.com";
        user = "git";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_rsa_azure";
      };
    };

    opencode.installDesktop = true;

    neovim = {
      enableDAP = false;
      languages = {
        csharp = true;
      };
    };
  };

  home.packages = with pkgs; [
    just
  ];
}
