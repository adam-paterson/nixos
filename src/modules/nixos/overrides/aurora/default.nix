{
  config,
  lib,
  ...
}: let
  cfg = config.cosmos.overrides.nixos.aurora;
in {
  options.cosmos.overrides.nixos.aurora.enable =
    lib.mkEnableOption "aurora-specific NixOS policy overrides";

  config = lib.mkIf cfg.enable {
    services = {
      cachix-agent.enable = true;
      vscode-server.enable = true;
    };

    # Let Home Manager move aside pre-existing dotfiles instead of failing activation.
    home-manager.backupFileExtension = "hm-backup";

    users.users.adam = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnvDtrxaduGQBC/YkKm4QcEvS8Tbn+h8pPLDi5d6wch"
      ];
    };
  };
}
