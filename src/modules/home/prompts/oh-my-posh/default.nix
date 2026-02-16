# ╭──────────────────────────────────────────────────────────╮
# │ Oh-My-Posh - Beautiful Cross-Shell Prompt                │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  ...
}: {
  options.local.oh-my-posh = {
    enable = lib.mkEnableOption "Oh-My-Posh prompt";
  };

  config = lib.mkIf config.local.oh-my-posh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      useTheme = "catppuccin";
    };
  };
}
