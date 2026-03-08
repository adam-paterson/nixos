{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.terminals.wezterm;
  weztermPkg = pkgs.wezterm;
  boolText = v:
    if v
    then "true"
    else "false";
in {
  options.${namespace}.home.terminals.wezterm = {
    enable = lib.mkEnableOption "WezTerm terminal emulator";

    profile = lib.mkOption {
      type = lib.types.enum [
        "default"
        "macbook"
      ];
      default = "default";
      description = "Profile-specific WezTerm overrides.";
    };

    theme.flavor = lib.mkOption {
      type = lib.types.enum [
        "mocha"
        "macchiato"
        "frappe"
        "latte"
      ];
      default = "mocha";
      description = "Catppuccin flavor to use in WezTerm.";
    };

    font = {
      family = lib.mkOption {
        type = lib.types.str;
        default = "Monaspace Neon";
        description = "Primary WezTerm font family.";
      };

      size = lib.mkOption {
        type = lib.types.float;
        default =
          if pkgs.stdenv.isDarwin
          then 14.0
          else 12.5;
        description = "WezTerm font size.";
      };
    };

    keys.mode = lib.mkOption {
      type = lib.types.enum [
        "leader"
        "direct"
        "hybrid"
      ];
      default = "leader";
      description = "Keybinding strategy for pane and workspace control.";
    };

    plugins = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable WezTerm plugin integrations.";
      };

      remote = {
        workspaceSwitcher = {
          url = lib.mkOption {
            type = lib.types.str;
            default = "https://github.com/MLFlexer/smart_workspace_switcher.wezterm";
            description = "Workspace switcher plugin URL.";
          };
          rev = lib.mkOption {
            type = lib.types.str;
            default = "40228a08e7bffb93b63b131df7f605278b5d8187";
            description = "Pinned revision for workspace switcher.";
          };
        };

        agentDeck = {
          url = lib.mkOption {
            type = lib.types.str;
            default = "https://github.com/Eric162/wezterm-agent-deck";
            description = "Agent deck plugin URL.";
          };
          rev = lib.mkOption {
            type = lib.types.str;
            default = "6fdd6ab";
            description = "Pinned revision for agent deck.";
          };
        };

        bar = {
          url = lib.mkOption {
            type = lib.types.str;
            default = "https://github.com/adriankarlen/bar.wezterm";
            description = "Bar plugin URL.";
          };
          rev = lib.mkOption {
            type = lib.types.str;
            default = "f4b1ab4";
            description = "Pinned revision for bar.";
          };
        };
      };
    };

    agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable agent-deck integration.";
      };
      notifications = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable agent waiting notifications.";
      };
      tabTitle = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show agent indicators in tab titles.";
      };
      rightStatus = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow agent plugin to own right status rendering.";
      };
    };

    bar = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable bar.wezterm integration.";
      };
      safeMode = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Conservative bar config to avoid runtime breakage.";
      };
    };

    style.macos = {
      blur = lib.mkOption {
        type = lib.types.int;
        default = 14;
        description = "macOS background blur amount.";
      };
      opacity = lib.mkOption {
        type = lib.types.float;
        default = 0.94;
        description = "Window background opacity on macOS.";
      };
      compactTabs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use denser tab layout for macOS.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm.lua;
    };

    home.packages =
      [
        weztermPkg
        pkgs.monaspace
      ]
      ++ lib.optionals cfg.plugins.enable [
        pkgs.zoxide
      ];

    xdg.configFile = {
      "wezterm/config/init.lua".source = ./config/init.lua;
      "wezterm/config/core.lua".source = ./config/core.lua;
      "wezterm/config/fonts.lua".source = ./config/fonts.lua;
      "wezterm/config/theme.lua".source = ./config/theme.lua;
      "wezterm/config/plugins.lua".source = ./config/plugins.lua;
      "wezterm/config/keymaps.lua".source = ./config/keymaps.lua;
      "wezterm/config/workspaces.lua".source = ./config/workspaces.lua;
      "wezterm/config/status.lua".source = ./config/status.lua;
      "wezterm/config/macbook.lua".source = ./config/macbook.lua;

      "wezterm/config/user.lua".text = ''
        return {
          profile = "${cfg.profile}",
          theme = {
            flavor = "${cfg.theme.flavor}",
          },
          font = {
            family = "${cfg.font.family}",
            size = ${toString cfg.font.size},
          },
          keys = {
            mode = "${cfg.keys.mode}",
          },
          shell = {
            program = "${pkgs.nushell}/bin/nu",
            args = { "-l" },
          },
          style = {
            macos = {
              blur = ${toString cfg.style.macos.blur},
              opacity = ${toString cfg.style.macos.opacity},
              compact_tabs = ${boolText cfg.style.macos.compactTabs},
            },
          },
          plugins = {
            enable = ${boolText cfg.plugins.enable},
            remote = {
              workspace_switcher = {
                url = "${cfg.plugins.remote.workspaceSwitcher.url}",
                rev = "${cfg.plugins.remote.workspaceSwitcher.rev}",
              },
              agent_deck = {
                url = "${cfg.plugins.remote.agentDeck.url}",
                rev = "${cfg.plugins.remote.agentDeck.rev}",
              },
              bar = {
                url = "${cfg.plugins.remote.bar.url}",
                rev = "${cfg.plugins.remote.bar.rev}",
              },
            },
          },
          agent = {
            enable = ${boolText cfg.agent.enable},
            notifications = ${boolText cfg.agent.notifications},
            tab_title = ${boolText cfg.agent.tabTitle},
            right_status = ${boolText cfg.agent.rightStatus},
          },
          bar = {
            enable = ${boolText cfg.bar.enable},
            safe_mode = ${boolText cfg.bar.safeMode},
          },
        }
      '';
    };
  };
}
