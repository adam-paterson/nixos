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
      ];
    };

    "macbook-002531" = {
      hostSecretsFile = inputs.self + "/secrets/hosts/macbook.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
      ];
    };
  };

  hostProfile = hostProfiles.${normalizedHostName} or null;
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
    ];

    sops = {
      age = {
        keyFile = lib.mkDefault "/Users/adampaterson/.config/sops/age/keys.txt";
        sshKeyPaths = [];
      };

      defaultSopsFile = hostProfile.hostSecretsFile;

      secrets = {
        "shared/onepassword/service_account_token" = {
          sopsFile = sharedSecretsFile;
        };
      };
    };
  };
}
