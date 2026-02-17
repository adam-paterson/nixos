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
          token = "cbb2262dda7be3f1f76b1fe1b2b5fa1bb47ce1fc56df933daa7d0c0225d54afe";
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
          ackReaction = "👍🏻";
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
