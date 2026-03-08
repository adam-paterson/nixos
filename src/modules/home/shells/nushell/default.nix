{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.shells.nushell;
  nushellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    ll = "eza -gl";
    la = "eza -gla";
    lt = "eza -T";
    tail = "tspin";
    gst = "git status -sb";
    glog = "git log --oneline --graph";
    vim = "nvim";
  };
  darwinCompatNushellDir = "${config.home.homeDirectory}/Library/Application Support/nushell";
in {
  options.${namespace}.home.shells.nushell.enable = lib.mkEnableOption "Nushell configuration";

  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      shellAliases = nushellAliases;
      settings = {
        show_banner = false;
        keybindings = [
          {
            name = "insert_newline";
            modifier = "control";
            keycode = "char_j";
            mode = [
              "emacs"
              "vi_normal"
              "vi_insert"
            ];
            event = {
              edit = "insertnewline";
            };
          }
        ];
        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
          sort = "smart";
          external = {
            enable = true;
            max_results = 200;
          };
        };
      };
      extraEnv = ''
        # Keep a deterministic Nix-first PATH while preserving inherited entries.
        let preferred_paths = [
          "/nix/var/nix/profiles/default/bin"
          $"($env.HOME)/.nix-profile/bin"
          $"/etc/profiles/per-user/($env.USER)/bin"
          "/run/current-system/sw/bin"
          $"($env.HOME)/.bun/bin"
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
        ]
        let inherited_path = (
          try { $env.PATH | split row (char esep) } catch { $env.PATH? | default [] }
        )
        $env.PATH = (
          $preferred_paths
          | append $inherited_path
          | each {|path_entry| $path_entry | into string }
          | where {|path_entry| ($path_entry | str length) > 0 and ($path_entry | path exists) }
          | uniq
        )
      '';
    };

    # Keep both Nushell config roots working on macOS for GUI/login shells.
    home.file = lib.mkIf (pkgs.stdenv.isDarwin && config.xdg.enable) {
      "${darwinCompatNushellDir}/config.nu" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nushell/config.nu";
        force = true;
      };
      "${darwinCompatNushellDir}/env.nu" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nushell/env.nu";
        force = true;
      };
    };
  };
}
