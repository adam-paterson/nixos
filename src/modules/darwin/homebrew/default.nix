{inputs, ...}: {
  nix-homebrew = {
    enable = true;
    user = "adampaterson";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "nikitabobko/homebrew-tap" = inputs.homebrew-aerospace;
    };
    # Taps can no longer be added imperatively with `brew tap`
    mutableTaps = false;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
  };
}
