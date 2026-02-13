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

  options.local.tailscale.installApp = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the Tailscale macOS app via Homebrew cask.";
  };

  config = lib.mkIf cfg.enable {
    homebrew = lib.mkIf cfg.installApp {
      enable = lib.mkDefault true;
      casks = lib.mkAfter ["tailscale-app"];
    };
  };
}
