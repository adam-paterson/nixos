{
  config,
  inputs,
  ...
}: {
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

    cloudflared = {
      enable = true;
      tunnelId = "01c993a2-1474-4c30-b93b-ca3958cf0728";
      credentialsFile = config.sops.secrets."hosts/aurora/cloudflared/credentials_json".path;
      ingress = {
        "app.example.com" = "http://127.0.0.1:3000";
      };
    };
  };

  system.stateVersion = "26.05";
}
