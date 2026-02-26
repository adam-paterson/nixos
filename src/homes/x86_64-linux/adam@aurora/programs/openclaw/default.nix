{ config, ... }:
let
  tokenFilePath = config.home.sessionVariables.OPENCLAW_GATEWAY_AUTH_TOKEN_FILE;
in
{
  assertions = [
    {
      assertion = tokenFilePath != null && tokenFilePath != "";
      message = ''
        OpenClaw gateway auth must consume a runtime secret token file path.
        Ensure OPENCLAW_GATEWAY_AUTH_TOKEN_FILE is exported from Home Manager secrets wiring.
      '';
    }
  ];

  programs.openclaw = {
    installApp = false;
    # ──[ Configuration ]───────────────────────────────────────────────────
    # This is an attribute set which matches the openclaw.json.
    # @see https://docs.openclaw.ai/gateway/configuration-reference
    # ──────────────────────────────────────────────────────────────────────
    config = {
      # ──[ Environment ]────────────────────────────────────────────────────
      # The environment section allows you to define environment variables
      # that will be available to the OpenClaw gateway and its components.
      # ────────────────────────────────────────────────────────────────────
      env = {
        shellEnv = {
          enabled = true;
          timeoutMs = 15000;
        };
      };

      # ──[ Gateway ]───────────────────────────────────────────────────────
      # The gateway is the core of OpenClaw responsible for managing
      # connections and routing traffic.
      # ────────────────────────────────────────────────────────────────────
      gateway = {
        mode = "local";
        port = 18500;
        bind = "loopback";
        auth = {
          mode = "token";
          tokenFile = tokenFilePath;
          allowTailscale = true;
        };
        tailscale = {
          mode = "serve";
          resetOnExit = false;
        };
        trustedProxies = [
          "100.77.42.103"
          "100.106.121.8"
        ];
      };

      # ──[ Channels ]───────────────────────────────────────────────────────
      # Channels define the communication pathways between different components
      # of OpenClaw. They allow for the exchange of data and messages in a
      # structured and controlled manner.
      # ────────────────────────────────────────────────────────────────────
      channels = {
        whatsapp = {
          ackReaction = {
            direct = true;
            group = "mentions";
            emoji = "✅";
          };
          accounts = {
            "adam" = {
              dmPolicy = "open";
              sendReadReceipts = true;
              allowFrom = [
                "*"
              ];
            };
            "rachel" = {
              dmPolicy = "open";
              sendReadReceipts = true;
              allowFrom = [
                "*"
              ];
            };
          };
        };
      };
    };
  };
}
