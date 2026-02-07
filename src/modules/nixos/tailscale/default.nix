{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.tailscale;
in {
  options.local.tailscale = {
    enable = lib.mkEnableOption "Tailscale on NixOS";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall rules required by Tailscale.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };

    environment.systemPackages = [
      pkgs.tailscale
    ];
  };
}
