{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.local.openclaw;
in {
  options.local.openclaw = {
    enable = lib.mkEnableOption "OpenClaw shared defaults for NixOS Home Manager users";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.openclaw.homeManagerModules.openclaw
      {
        # Linux launch management on apply.
        programs.openclaw = {
          enable = lib.mkDefault true;
          installApp = lib.mkDefault false;
          launchd.enable = lib.mkDefault false;
          systemd.enable = lib.mkDefault true;

          # Shared repo-managed documents applied per instance workspace.
          documents = lib.mkDefault ../../../config/openclaw/documents;

          # Shared baseline config inherited by all user-defined instances.
          config = lib.mkDefault {
            gateway = {
              mode = "local";
              bind = "loopback";
              auth = {
                mode = "token";
                token = "{env:OPENCLAW_GATEWAY_TOKEN}";
              };
            };
            env = {
              shellEnv = {
                enabled = true;
                timeoutMs = 6000;
              };
              vars = {
                OPENAI_API_KEY = "{env:OPENAI_API_KEY}";
                ANTHROPIC_API_KEY = "{env:ANTHROPIC_API_KEY}";
                FIREWORKS_API_KEY = "{env:FIREWORKS_API_KEY}";
              };
            };
            browser = {
              enabled = true;
              headless = true;
            };
          };

          # Default Linux-compatible bundled tools.
          bundledPlugins = {
            # Enable bundled plugins by default, but allow users to disable them if desired.
            summarize.enable = lib.mkDefault true;
            oracle.enable = lib.mkDefault true;
            goplaces.enable = lib.mkDefault true;
          };
        };
      }
    ];
  };
}
