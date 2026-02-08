{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.onePasswordSSH;
  defaultSocket =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "${config.home.homeDirectory}/.1password/agent.sock";
  hostType = lib.types.submodule (_: {
    options = {
      hostName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional HostName value for this SSH host block.";
      };

      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional User for this SSH host block.";
      };

      port = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional SSH port.";
      };

      identitiesOnly = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set IdentitiesOnly for this SSH host block. Keep disabled when relying on 1Password SSH agent bookmarks.";
      };

      identityFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional IdentityFile for this SSH host block.";
      };

      identityAgent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional IdentityAgent override. Set to \"none\" to disable agent usage for this host.";
      };

      preferredAuthentications = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional PreferredAuthentications value.";
      };

      pubkeyAuthentication = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Optional PubkeyAuthentication setting for this host.";
      };
    };
  });
  hostMatchBlocks = lib.mapAttrs (_: hostCfg: ({
      inherit (hostCfg) identitiesOnly;
    }
    // lib.optionalAttrs (hostCfg.hostName != null) {
      hostname = hostCfg.hostName;
    }
    // lib.optionalAttrs (hostCfg.user != null) {
      inherit (hostCfg) user;
    }
    // lib.optionalAttrs (hostCfg.port != null) {
      inherit (hostCfg) port;
    }
    // lib.optionalAttrs (hostCfg.identityFile != null) {
      inherit (hostCfg) identityFile;
    }
    // lib.optionalAttrs (hostCfg.identityAgent != null) {
      inherit (hostCfg) identityAgent;
    }
    // lib.optionalAttrs (hostCfg.preferredAuthentications != null) {
      inherit (hostCfg) preferredAuthentications;
    }
    // lib.optionalAttrs (hostCfg.pubkeyAuthentication != null) {
      inherit (hostCfg) pubkeyAuthentication;
    }))
  cfg.hosts;
in {
  options.local.onePasswordSSH = {
    enable = lib.mkEnableOption "1Password SSH agent integration";

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = defaultSocket;
      description = "Path to the 1Password SSH agent socket.";
    };

    includeBookmarkConfig = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isDarwin;
      description = "Include 1Password-generated SSH bookmark config.";
    };

    bookmarkConfigPath = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/1Password/config";
      description = "Path to the 1Password-generated SSH bookmark config file.";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf hostType;
      default = {};
      description = "Host-specific SSH config blocks merged with 1Password agent defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = lib.optional cfg.includeBookmarkConfig cfg.bookmarkConfigPath;
      matchBlocks =
        {
          "*" = {
            # SSH config needs quotes when paths contain spaces (common on macOS for 1Password).
            identityAgent = "\"${cfg.socketPath}\"";
          };
        }
        // hostMatchBlocks;
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = cfg.socketPath;
    };
  };
}
