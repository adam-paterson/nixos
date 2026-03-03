{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.home.security.secrets;
  sharedSecretsFile = inputs.self + "/secrets/shared/common.yaml";
  openclawGatewaySecretName = "hosts/aurora/openclaw/gateway_auth_token";

  userProfiles = {
    adam = {
      hostSecretsFile = inputs.self + "/secrets/hosts/aurora.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
        openclawGatewaySecretName
      ];
      exportMacbookSshPath = false;
      exportOpenclawGatewayAuthTokenPath = true;
    };

    adampaterson = {
      hostSecretsFile = inputs.self + "/secrets/hosts/macbook.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
      ];
      exportMacbookSshPath = true;
      exportOpenclawGatewayAuthTokenPath = false;
    };
  };

  userProfile = userProfiles.${config.home.username} or null;
  declaredSecretNames = builtins.attrNames config.sops.secrets;
  missingRequiredSecretNames =
    if userProfile == null
    then []
    else lib.filter (name: !(lib.elem name declaredSecretNames)) userProfile.requiredSecretNames;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.${namespace}.home.security.secrets.enable =
    lib.mkEnableOption "runtime-only Home Manager secret wiring";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = userProfile != null;
        message = ''
          home.security.secrets.enable is true, but no secret profile exists for home.username "${config.home.username}".
          Add user secret mappings under src/modules/home/security/secrets/default.nix.
        '';
      }
      {
        assertion = missingRequiredSecretNames == [];
        message = ''
          Missing required Home Manager SOPS secret declarations for user "${config.home.username}":
          ${lib.concatStringsSep ", " missingRequiredSecretNames}
          Ensure encrypted files contain these keys and this module declares them.
        '';
      }
      {
        assertion =
          userProfile
          == null
          || (!userProfile.exportOpenclawGatewayAuthTokenPath)
          || lib.elem openclawGatewaySecretName userProfile.requiredSecretNames;
        message = ''
          OpenClaw runtime secret export is enabled for user "${config.home.username}" but "${openclawGatewaySecretName}" is not listed as required.
          Keep runtime-only OpenClaw token wiring guarded by requiredSecretNames to fail fast when secret declarations drift.
        '';
      }
    ];

    sops = {
      age = {
        keyFile = lib.mkDefault "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
      defaultSopsFile = userProfile.hostSecretsFile;

      gnupg = {
        sshKeyPaths = [];
      };

      secrets = {
        "shared/onepassword/service_account_token" = {
          sopsFile = sharedSecretsFile;
        };
      };
    };

    home.sessionVariables = {
      OP_SERVICE_ACCOUNT_TOKEN_FILE = config.sops.secrets."shared/onepassword/service_account_token".path;
    };
  };
}
