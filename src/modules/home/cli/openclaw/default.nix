{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.home.cli.openclaw;
in
{
  options.${namespace}.home.cli.openclaw.enable = lib.mkEnableOption "OpenClaw Home Manager module";

  imports = [
    inputs.openclaw.homeManagerModules.openclaw
  ];

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      enable = true;
      package = pkgs.openclaw;
    };

    # Native zsh completion via openclaw's Commander.js completion generator.
    # openclaw is a Node.js/Commander.js CLI (not Cobra), so we use its own
    # completion command rather than the Cobra bridge.
    programs.zsh.initContent = lib.mkAfter ''
      source <(openclaw completion -s zsh)
    '';

    # Carapace bridge spec for nushell. Commander.js has no carapace bridge,
    # so we use the Zsh bridge which invokes the registered zsh completion.
    # This requires the zsh completion above to be loaded in the zsh config
    # that carapace's Zsh bridge can reach.
    xdg.configFile."carapace/specs/openclaw.yaml".text = ''
      # yaml-language-server: $schema=https://carapace.sh/schemas/command.json
      name: openclaw
      description: Openclaw cli
      parsing: disabled
      completion:
        positionalany: ["$carapace.bridge.Zsh([openclaw])"]
    '';
  };
}
