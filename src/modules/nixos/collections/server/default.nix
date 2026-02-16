{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.nixos.server;
in {
  options.local.collections.nixos.server.enable = lib.mkEnableOption "server NixOS collection";

  config = lib.mkIf cfg.enable {
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
