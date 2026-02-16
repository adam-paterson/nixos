{
  config,
  lib,
  ...
}: let
  cfg = config.local.collections.home.dev;
in {
  options.local.collections.home.dev.enable = lib.mkEnableOption "developer tooling home collection";

  config = lib.mkIf cfg.enable {
    local = {
      neovim = {
        enable = lib.mkDefault true;
        enableAI = lib.mkDefault true;
        enableDAP = lib.mkDefault false;
        languages = {
          typescript = lib.mkDefault true;
          python = lib.mkDefault false;
          go = lib.mkDefault true;
          rust = lib.mkDefault true;
          nix = lib.mkDefault true;
          csharp = lib.mkDefault false;
        };
      };
      tailwind.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
    };
  };
}
