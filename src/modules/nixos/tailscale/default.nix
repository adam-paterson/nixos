{
  config,
  lib,
  ...
}: let
  cfg = config.local.tailscale;
in {
  imports = [
    ../../common/tailscale
  ];

  options.local.tailscale.openFirewall = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Open firewall rules required by Tailscale.";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.openFirewall = cfg.openFirewall;
  };
}
