{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.tailwind = {
    enable = lib.mkEnableOption "Tailwind CSS";
  };

  config = lib.mkIf config.local.tailwind.enable {
    home.packages = with pkgs; [
      tailwindcss
    ];
  };
}
