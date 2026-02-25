{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.cosmos.security.secrets.nixos;
  sharedSecretsFile = inputs.self + "/secrets/shared/common.yaml";
  normalizedHostName = lib.toLower config.networking.hostName;

  hostProfiles = {
    aurora = {
      hostSecretsFile = inputs.self + "/secrets/hosts/aurora.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
        "shared/cloudflare/tunnel_id"
        "hosts/aurora/cloudflared/credentials_json"
      ];
    };
  };

  hostProfile = hostProfiles.${normalizedHostName} or null;
  declaredSecretNames = builtins.attrNames config.sops.secrets;
  missingRequiredSecretNames =
    if hostProfile == null
    then []
    else lib.filter (name: !(lib.elem name declaredSecretNames)) hostProfile.requiredSecretNames;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.cosmos.security.secrets.nixos.enable =
    lib.mkEnableOption "runtime-only NixOS secret wiring";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hostProfile != null;
        message = ''
          cosmos.security.secrets.nixos.enable is true, but no host profile exists for "${config.networking.hostName}".
          Add host secret mappings under src/modules/nixos/security/secrets/default.nix.
        '';
      }
      {
        assertion = missingRequiredSecretNames == [];
        message = ''
          Missing required SOPS secret declarations for host "${config.networking.hostName}":
          ${lib.concatStringsSep ", " missingRequiredSecretNames}
          Ensure the encrypted host/shared files include these keys and that this module declares them.
        '';
      }
    ];

    sops = {
      defaultSopsFile = hostProfile.hostSecretsFile;

      secrets = {
        "shared/onepassword/service_account_token" = {
          sopsFile = sharedSecretsFile;
        };

        "shared/cloudflare/tunnel_id" = {
          sopsFile = sharedSecretsFile;
        };

        "hosts/aurora/cloudflared/credentials_json" = {
          owner = "root";
          group = "root";
          mode = "0400";
          path = "/run/secrets/cloudflared-credentials.json";
        };
      };
    };
  };
}
