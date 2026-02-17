{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.tailscale;
in {
  options.cosmos.tailscale.enable = lib.mkEnableOption "Tailscale";

  options.cosmos.tailscale.installApp = lib.mkOption {
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
