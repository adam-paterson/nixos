{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.tailscale;
in {
  options.local.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    environment.systemPackages = [
      pkgs.tailscale
    ];
  };
}
