{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cosmos.tailscale;
in {
  options.cosmos.tailscale.enable = lib.mkEnableOption "Tailscale";

  options.cosmos.tailscale.openFirewall = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Open firewall rules required by Tailscale.";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    services.tailscale.openFirewall = cfg.openFirewall;

    environment.systemPackages = [
      pkgs.tailscale
    ];
  };
}
