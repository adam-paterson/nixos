{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.cosmos.security.secrets.darwin;
  sharedSecretsFile = inputs.self + "/secrets/shared/common.yaml";
  normalizedHostName = lib.toLower config.networking.hostName;

  hostProfiles = {
    macbook = {
      hostSecretsFile = inputs.self + "/secrets/hosts/macbook.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
        "hosts/macbook/local/ssh_private_key"
      ];
    };

    "macbook-002531" = {
      hostSecretsFile = inputs.self + "/secrets/hosts/macbook.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
        "hosts/macbook/local/ssh_private_key"
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
    inputs.sops-nix.darwinModules.sops
  ];

  options.cosmos.security.secrets.darwin.enable =
    lib.mkEnableOption "runtime-only nix-darwin secret wiring";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hostProfile != null;
        message = ''
          cosmos.security.secrets.darwin.enable is true, but no host profile exists for "${config.networking.hostName}".
          Add host secret mappings under src/modules/darwin/security/secrets/default.nix.
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

        "hosts/macbook/local/ssh_private_key" = {};
      };
    };
  };
}
