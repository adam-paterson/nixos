{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.cli.openclaw;
in {
  options.${namespace}.home.cli.openclaw.enable = lib.mkEnableOption "OpenClaw Home Manager module";

  imports = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      enable = true;
      package = pkgs.openclaw;
    };

    xdg.configFile."carapace/specs/openclaw.yaml".text = ''
      # yaml-language-server: $schema=https://carapace.sh/schemas/command.json
      name: openclaw
      description: Openclaw cli
      parsing: disabled
      completion:
        positionalany: ["$carapace.bridge.Cobra([openclaw])]"]
    '';
  };
}
