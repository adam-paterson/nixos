{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.fd;
in {
  options.${namespace}.home.cli.fd.enable = lib.mkEnableOption "fd";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.fd];
  };
}
