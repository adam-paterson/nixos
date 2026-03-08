{inputs, ...}: {
  imports = [
    inputs.vscode-server.nixosModules.default
    ./hardware
  ];

  networking = {
    hostName = "aurora";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "UTC";

  cosmos = {
    collections.nixos.server.enable = true;
    overrides.nixos.aurora.enable = true;

    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  system.stateVersion = "26.05";
}
