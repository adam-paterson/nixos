{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.collections.nixos.server;
in {
  options.cosmos.collections.nixos.server.enable = lib.mkEnableOption "server NixOS collection";

  config = lib.mkIf cfg.enable {
    cosmos = {
      collections.nixos.base.enable = lib.mkDefault true;
      overrides.nixos.aurora.enable = lib.mkDefault false;
      security.secrets.nixos.enable = lib.mkDefault true;
    };

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
