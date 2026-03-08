{
  config,
  lib,
  inputs,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.desktop.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  options.${namespace}.home.desktop.spotify = {
    enable = lib.mkEnableOption "Spotify desktop client";
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        fullAppDisplay
        shuffle
        loopyLoop
        popupLyrics
        trashbin
        wikify
        history
        betterGenres
        lastfm
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
