{...}: {
  imports = [
    ./hardware
    ./openclaw
  ];

  networking = {
    hostName = "aurora";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services = {
    cachix-agent.enable = true;
    vscode-server.enable = true;
  };

  time.timeZone = "UTC";

  local.tailscale = {
    enable = true;
    openFirewall = true;
  };

  local.cloudflared = {
    enable = true;
    tunnelId = "01c993a2-1474-4c30-b93b-ca3958cf0728";
    credentialsFile = "/var/lib/cloudflared/01c993a2-1474-4c30-b93b-ca3958cf0728.json";
    ingress = {
      "app.example.com" = "http://127.0.0.1:3000";
    };
  };

  # Let Home Manager move aside pre-existing dotfiles instead of failing activation.
  home-manager.backupFileExtension = "hm-backup";

  users.users.adam = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnvDtrxaduGQBC/YkKm4QcEvS8Tbn+h8pPLDi5d6wch"
    ];
  };

  system.stateVersion = "26.05";
}
