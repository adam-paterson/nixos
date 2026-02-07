{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "aurora";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "UTC";

  users.users.adam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Replace with your real public key before first deploy.
      "ssh-ed25519 REPLACE_ME"
    ];
  };

  system.stateVersion = "24.11";
}
