{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.overrides.darwin.macbook;
in {
  options.cosmos.overrides.darwin.macbook.enable =
    lib.mkEnableOption "macbook-specific Darwin override policy";

  config = lib.mkIf cfg.enable {
    cosmos = {
      darwin.input = {
        enable = lib.mkDefault true;
        remapCapsLockToControl = lib.mkDefault true;
        keyRepeat = lib.mkDefault 2;
        initialKeyRepeat = lib.mkDefault 15;
      };

      tailscale = {
        enable = lib.mkDefault true;
        installApp = lib.mkDefault true;
      };
    };

    homebrew = {
      taps = lib.mkAfter ["nikitabobko/tap"];
      casks = lib.mkAfter [
        "ghostty"
        "obsidian"
        "aerospace"
      ];
    };
  };
}
