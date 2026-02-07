{...}: {
  imports = [
    ./hardware
  ];

  networking = {
    hostName = "aurora";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "UTC";

  users.users.adam = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnvDtrxaduGQBC/YkKm4QcEvS8Tbn+h8pPLDi5d6wch"
    ];
  };

  system.stateVersion = "24.11";
}
