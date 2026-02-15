_: {
  programs.openclaw = {
    bundledPlugins = {
      oracle.enable = true;
      sag.enable = true;
      gogcli.enable = true;
      goplaces.enable = true;
    };

    plugins = [
      {source = "github:openclaw/nix-steipete-tools";}
    ];
  };
}
