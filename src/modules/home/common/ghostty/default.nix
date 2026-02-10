# ╭──────────────────────────────────────────────────────────╮
# │ Ghostty - GPU-Accelerated Terminal                       │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal configuration";
  };

  config = lib.mkIf config.local.ghostty.enable {
    programs.ghostty = {
      enable = true;

      # Use pre-built binary on macOS for better compatibility
      package = lib.mkIf pkgs.stdenv.isDarwin pkgs.ghostty-bin;

      settings = {
        # Theme
        theme = "Catppuccin Mocha";

        # Font configuration
        font-family = "JetBrainsMono Nerd Font";
        font-family-italic = "JetBrainsMono Nerd Font Italic";
        font-feature = "ss01";

        # Cell adjustments for better readability
        adjust-cell-height = "50%";
        adjust-cursor-height = "50%";

        # Window padding
        window-padding-x = 0;
        window-padding-y = 0;

        # Default shell
        command = "${pkgs.nushell}/bin/nu";

        # Additional settings
        window-decoration = true;
        background-opacity = 1.0;
        cursor-style = "block";
        cursor-style-blink = false;
        shell-integration = "detect";

        # macOS-specific
        macos-option-as-alt = true;

        # Keybindings
        keybind = [
          "cmd+shift+t=new_tab"
          "cmd+shift+w=close_tab"
          "cmd+shift+n=new_window"
          "cmd+shift+bracket_left=previous_tab"
          "cmd+shift+bracket_right=next_tab"
          "cmd+plus=increase_font_size:1"
          "cmd+minus=decrease_font_size:1"
          "cmd+0=reset_font_size"
        ];
      };
    };
  };
}
