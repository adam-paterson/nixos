_: {
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
          # auth.token is intentionally omitted here — the gateway reads the
          # token at runtime via OPENCLAW_GATEWAY_AUTH_TOKEN_FILE (exported
          # as a session variable by src/modules/home/security/secrets).
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
