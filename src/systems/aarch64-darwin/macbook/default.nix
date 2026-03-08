{lib, ...}: {
  networking = {
    hostName = lib.mkForce "MACBOOK-002531";
    computerName = lib.mkForce "MACBOOK-002531";
    localHostName = lib.mkForce "MACBOOK-002531";
  };

  # Set to your local macOS username.
  system.primaryUser = "adampaterson";

  cosmos = {
    collections.darwin.workstation.enable = true;
    overrides.darwin.macbook.enable = true;
  };

  system.stateVersion = 6;
}
