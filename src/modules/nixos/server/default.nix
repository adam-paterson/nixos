_: {
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
}
