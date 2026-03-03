# ╭──────────────────────────────────────────────────────────╮
# │ Oh-My-Posh - Beautiful Cross-Shell Prompt                │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  namespace,
  ...
}: {
  options.${namespace}.home.prompts.ohMyPosh = {
    enable = lib.mkEnableOption "Oh-My-Posh prompt";
  };

  config = lib.mkIf config.${namespace}.home.prompts.ohMyPosh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      useTheme = "catppuccin";
    };
  };
}
