{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.nixos.server;
in {
  options.local.collections.nixos.server.enable = lib.mkEnableOption "server NixOS collection";

  config = lib.mkIf cfg.enable {
    local.collections.nixos.base.enable = lib.mkDefault true;

    services.fail2ban.enable = true;

    security.sudo = {
      wheelNeedsPassword = true;
      execWheelOnly = true;
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
    };
  };
}
