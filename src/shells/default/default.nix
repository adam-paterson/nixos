{
  pkgs,
  inputs,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      {pkgs, ...}: {
        # Ensure flake evaluation in CI has a stable root for devenv.
        devenv.root = toString ../../..;

        cachix.pull = ["adam-paterson"];

        packages = with pkgs; [
          nixd
          alejandra
          statix
          deadnix
          just
          git
        ];

        git-hooks.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;

          fmt-check = {
            enable = true;
            name = "fmt-check";
            entry = "${pkgs.just}/bin/just fmt-check";
            pass_filenames = false;
          };

          eval = {
            enable = true;
            name = "eval";
            entry = "${pkgs.just}/bin/just eval";
            pass_filenames = false;
          };
        };
      }
    )
  ];
}
