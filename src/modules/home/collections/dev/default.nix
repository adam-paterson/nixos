{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.collections.dev;
in {
  options.${namespace}.home.collections.dev.enable = lib.mkEnableOption "developer tooling home collection";

  config = lib.mkIf cfg.enable {
    ${namespace}.home = {
      runtimes.bun = {
        enable = lib.mkDefault true;
        reconcile = lib.mkDefault "install-only";
        globalPackages = lib.mkDefault {
          beads = "github:steveyegge/beads";
        };
      };

      editors.neovim = {
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

      terminals.tmux.enable = lib.mkDefault true;
      cli.tailspin.enable = lib.mkDefault true;
    };
  };
}
