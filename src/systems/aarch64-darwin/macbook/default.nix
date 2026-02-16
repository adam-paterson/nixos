{lib, ...}: {
  networking = {
    hostName = lib.mkForce "MACBOOK-002531";
    computerName = lib.mkForce "MACBOOK-002531";
    localHostName = lib.mkForce "MACBOOK-002531";
  };

  # Set to your local macOS username.
  system.primaryUser = "adampaterson";

  local = {
    collections.darwin.workstation.enable = true;

    darwin.input = {
      enable = true;
      remapCapsLockToControl = true;
      keyRepeat = 2;
      initialKeyRepeat = 15;
    };

    tailscale = {
      enable = true;
      installApp = true;
    };
  };

  homebrew = {
    casks = [
      "ghostty"
      "obsidian"
      "aerospace"
    ];

    taps = ["nikitabobko/tap"];
  };

  system.stateVersion = "26.05";
}
