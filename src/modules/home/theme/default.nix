{
  inputs,
  lib,
  namespace,
  config,
  ...
}: let
  cfg = config.${namespace}.home.theme;
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  options.${namespace}.home.theme = {
    enable = lib.mkEnableOption "Catppuccin theme integrations";

    accent = lib.mkOption {
      type = lib.types.enum [
        "rosewater"
        "flamingo"
        "pink"
        "mauve"
        "red"
        "maroon"
        "peach"
        "yellow"
        "green"
        "teal"
        "sky"
        "sapphire"
        "blue"
        "lavender"
      ];
      default = "mauve";
      description = "The accent color to use for the theme.";
    };

    flavor = lib.mkOption {
      type = lib.types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
      description = "The flavor of the theme to use.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        catppuccin = {
          enable = true;
          inherit (cfg) accent flavor;
        };
      }

      (lib.mkIf config.${namespace}.home.shells.viewers.bat.enable {
        catppuccin.bat.enable = true;
        catppuccin.bat.flavor = cfg.flavor;
      })

      (lib.mkIf config.${namespace}.home.terminals.wezterm.enable {
        catppuccin.wezterm = {
          enable = true;
          apply = true;
          inherit (cfg) flavor;
        };
      })

      (lib.mkIf config.${namespace}.home.shells.nushell.enable {
        catppuccin.nushell = {
          enable = true;
          inherit (cfg) flavor;
        };
      })

      (lib.mkIf config.${namespace}.home.cli.fzf.enable {
        catppuccin.fzf = {
          enable = true;
          inherit (cfg) flavor;
        };
      })
    ]
  );
}
