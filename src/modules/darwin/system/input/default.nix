{ config, lib, ... }:
let
  cfg = config.local.darwin.input;
in
{
  options.local.darwin.input = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable shared macOS keyboard/input defaults.";
    };

    remapCapsLockToControl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remap Caps Lock to Control.";
    };

    keyRepeat = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "macOS key repeat rate (lower is faster).";
    };

    initialKeyRepeat = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Delay before key repeat starts.";
    };
  };

  config = lib.mkIf cfg.enable {
    system = {
      keyboard = {
        enableKeyMapping = lib.mkDefault cfg.remapCapsLockToControl;
        remapCapsLockToControl = lib.mkDefault cfg.remapCapsLockToControl;

        # Remap ISO Section key (§/±) to Grave Accent/Tilde (`/~)
        # This fixes external keyboards like Keychron Q1 that send ISO scancode
        # 0x64 (ISO Section) instead of 0x35 (Grave Accent)
        userKeyMapping = [
          # ISO Section key (§/±) -> Grave Accent/Tilde (`/~)
          {
            HIDKeyboardModifierMappingSrc = 30064771172; # 0x700000064
            HIDKeyboardModifierMappingDst = 30064771125; # 0x700000035
          }
        ];
      };

      defaults = {
        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = true;
        };

        CustomUserPreferences = {
          NSGlobalDomain = {
            AppleLocale = "en_GB";
            AppleLanguages = [ "en-GB" ];
          };

          "com.apple.HIToolbox" = {
            AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.British";
            AppleDefaultAsciiInputSource = {
              InputSourceKind = "Keyboard Layout";
              "KeyboardLayout ID" = 2;
              "KeyboardLayout Name" = "British";
            };
            AppleEnabledInputSources = [
              {
                InputSourceKind = "Keyboard Layout";
                "KeyboardLayout ID" = 2;
                "KeyboardLayout Name" = "British";
              }
            ];
            AppleSelectedInputSources = [
              {
                InputSourceKind = "Keyboard Layout";
                "KeyboardLayout ID" = 2;
                "KeyboardLayout Name" = "British";
              }
            ];
          };
        };

        NSGlobalDomain = {
          AppleKeyboardUIMode = 3; # Full keyboard access
          ApplePressAndHoldEnabled = false;
          AppleScrollerPagingBehavior = true;
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          KeyRepeat = lib.mkDefault cfg.keyRepeat;
          InitialKeyRepeat = lib.mkDefault cfg.initialKeyRepeat;
        };
      };
    };
  };
}
