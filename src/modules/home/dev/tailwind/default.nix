{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cosmos.tailwind = {
    enable = lib.mkEnableOption "Tailwind CSS";
  };

  config = lib.mkIf config.cosmos.tailwind.enable {
    home.packages = with pkgs; [
      tailwindcss
    ];
  };
}
