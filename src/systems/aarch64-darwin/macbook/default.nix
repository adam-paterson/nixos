{lib, ...}: {
  networking.hostName = lib.mkForce "MACBOOK-002531";
  networking.computerName = lib.mkForce "MACBOOK-002531";
  networking.localHostName = lib.mkForce "MACBOOK-002531";

  # Set to your local macOS username.
  system.primaryUser = "adampaterson";

  local.darwin.input = {
    enable = true;
    remapCapsLockToControl = true;
    keyRepeat = 2;
    initialKeyRepeat = 15;
  };

  local.tailscale = {
    enable = true;
    installApp = true;
  };

  system.stateVersion = "26.05";
}
