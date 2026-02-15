{inputs, ...}: {
  imports = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  programs.openclaw = {
    config = {
      gateway = {
        mode = "local";
        port = 18789;
        bind = "tailnet";
        auth = {
          mode = "token";
          token = "f2200a27b3a0c1c1a893c243f1e05821da8b8ea69b2b3446";
          allowTailscale = true;
        };
        tailscale = {
          mode = "off";
        };
      };

      channels.whatsapp = {
        accounts = {
          default = {
            enabled = true;
            name = "default";
          };
        };
      };
    };
    instances = {
      default = {
        enable = true;
      };
    };
  };
}
