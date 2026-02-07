{ config, lib, pkgs, ... }:
let
  cfg = config.local.onePasswordSSH;
  defaultSocket =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  options.local.onePasswordSSH = {
    enable = lib.mkEnableOption "1Password SSH agent integration";

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = defaultSocket;
      description = "Path to the 1Password SSH agent socket.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        identityAgent = cfg.socketPath;
      };
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = cfg.socketPath;
    };
  };
}
