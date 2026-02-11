{lib, ...}: {
  home-manager.sharedModules = [
    {
      # OpenClaw available on all NixOS Home Manager users by default.
      programs.openclaw.enable = lib.mkDefault true;

      # Linux launch management on apply.
      programs.openclaw.installApp = lib.mkDefault false;
      programs.openclaw.launchd.enable = lib.mkDefault false;
      programs.openclaw.systemd.enable = lib.mkDefault true;

      # Shared repo-managed documents applied per instance workspace.
      programs.openclaw.documents = lib.mkDefault ../../../config/openclaw/documents;

      # Shared baseline config inherited by all user-defined instances.
      programs.openclaw.config = lib.mkDefault {
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
          };
        };
        browser = {
          enabled = true;
          evaluateEnabled = true;
          headless = true;
        };
      };

      # Default Linux-compatible bundled tools.
      programs.openclaw.bundledPlugins.summarize.enable = lib.mkDefault true;
      programs.openclaw.bundledPlugins.oracle.enable = lib.mkDefault true;
      programs.openclaw.bundledPlugins.goplaces.enable = lib.mkDefault true;
    }
  ];
}
