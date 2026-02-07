{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.cloudflared;
  ingressList =
    (map
      (
        host: let
          value = cfg.ingress.${host};
        in
          if builtins.isString value
          then {
            hostname = host;
            service = value;
          }
          else ({hostname = host;} // value)
      )
      (builtins.attrNames cfg.ingress))
    ++ [
      {
        service = cfg.defaultService;
      }
    ];

  cloudflaredConfig =
    pkgs.writeText "cloudflared-${cfg.tunnelId}.json"
    (builtins.toJSON (
      {
        tunnel = cfg.tunnelId;
        "credentials-file" = cfg.credentialsFile;
        ingress = ingressList;
      }
      // lib.optionalAttrs (cfg.originRequest != {}) {
        originRequest = cfg.originRequest;
      }
    ));
in {
  options.local.cloudflared = {
    enable = lib.mkEnableOption "Cloudflared tunnel service";

    installCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install cloudflared CLI in system packages.";
    };

    tunnelId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Cloudflare tunnel UUID (used as services.cloudflared.tunnels.<id>).";
      example = "00000000-0000-0000-0000-000000000000";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/cloudflared/tunnel-credentials.json";
      description = "Absolute path to the tunnel credentials JSON file.";
    };

    certificateFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional Cloudflare account cert.pem for declarative route management.";
    };

    ingress = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.attrs);
      default = {};
      description = "Ingress mapping of hostnames to services (for example app.example.com -> http://127.0.0.1:3000).";
      example = {
        "app.example.com" = "http://127.0.0.1:3000";
        "ssh.example.com" = "ssh://localhost:22";
      };
    };

    defaultService = lib.mkOption {
      type = lib.types.str;
      default = "http_status:404";
      description = "Catch-all ingress backend when no hostname rules match.";
    };

    originRequest = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Optional originRequest tuning passed to cloudflared.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.installCli {
      environment.systemPackages = [
        pkgs.cloudflared
      ];
    })

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.tunnelId != null;
          message = "local.cloudflared.tunnelId must be set when local.cloudflared.enable = true.";
        }
        {
          assertion = builtins.length (builtins.attrNames cfg.ingress) > 0;
          message = "local.cloudflared.ingress must define at least one hostname rule when local.cloudflared.enable = true.";
        }
      ];

      systemd.services."cloudflared-tunnel-${cfg.tunnelId}" = {
        description = "Cloudflared tunnel ${cfg.tunnelId}";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        wants = ["network-online.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config=${cloudflaredConfig} --no-autoupdate run";
          Restart = "on-failure";
          RestartSec = "5s";
          User = "root";
          Group = "root";
        };
      };
    })
  ];
}
