{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.cosmos.security.secrets.home;
  sharedSecretsFile = inputs.self + "/secrets/shared/common.yaml";

  userProfiles = {
    adam = {
      hostSecretsFile = inputs.self + "/secrets/hosts/aurora.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
      ];
      exportMacbookSshPath = false;
    };

    adampaterson = {
      hostSecretsFile = inputs.self + "/secrets/hosts/macbook.yaml";
      requiredSecretNames = [
        "shared/onepassword/service_account_token"
        "hosts/macbook/local/ssh_private_key"
      ];
      exportMacbookSshPath = true;
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

  options.cosmos.security.secrets.home.enable =
    lib.mkEnableOption "runtime-only Home Manager secret wiring";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = userProfile != null;
        message = ''
          cosmos.security.secrets.home.enable is true, but no secret profile exists for home.username "${config.home.username}".
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
    ];

    sops = {
      age.keyFile = lib.mkDefault "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = userProfile.hostSecretsFile;

      secrets =
        {
          "shared/onepassword/service_account_token" = {
            sopsFile = sharedSecretsFile;
          };
        }
        // lib.optionalAttrs userProfile.exportMacbookSshPath {
          "hosts/macbook/local/ssh_private_key" = {};
        };
    };

    home.sessionVariables =
      {
        OP_SERVICE_ACCOUNT_TOKEN_FILE = config.sops.secrets."shared/onepassword/service_account_token".path;
      }
      // lib.optionalAttrs userProfile.exportMacbookSshPath {
        COSMOS_LOCAL_SSH_PRIVATE_KEY_FILE = config.sops.secrets."hosts/macbook/local/ssh_private_key".path;
      };
  };
}
