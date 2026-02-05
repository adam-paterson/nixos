# Agenix Secrets Configuration
# Define your encrypted secrets and who can decrypt them
# 
# Usage:
# 1. Generate SSH keys for your users and hosts
# 2. Add public keys below
# 3. Create secrets with: agenix -e secrets/example-secret.age
# 4. Use secrets in your configuration with: config.age.secrets.example-secret.path

let
  # ============================================================================
  # User SSH Public Keys
  # ============================================================================
  # Add your user SSH public keys here
  # Get them with: cat ~/.ssh/id_ed25519.pub (or your key type)
  
  # TODO: Replace with your actual SSH public keys
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleUserKey1 user@example";
  # user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleUserKey2 user2@example";
  
  users = [ user1 ];

  # ============================================================================
  # Host SSH Public Keys
  # ============================================================================
  # Add your host SSH public keys here
  # Get them with: sudo cat /etc/ssh/ssh_host_ed25519_key.pub
  
  # TODO: Replace with your actual host SSH public keys
  example-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleHostKey1 root@example-nixos";
  example-darwin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleHostKey2 root@example-darwin";
  
  systems = [ example-nixos example-darwin ];

in
{
  # ============================================================================
  # Secret Definitions
  # ============================================================================
  # Define secrets and who can decrypt them
  # 
  # Syntax: "secret-name.age".publicKeys = [ list of authorized keys ];
  # 
  # To create/edit a secret:
  #   agenix -e secrets/secret-name.age
  #
  # To use a secret in your config:
  #   age.secrets.secret-name.file = ../secrets/secret-name.age;
  #   # Then access with: config.age.secrets.secret-name.path
  
  # Example secrets
  "example-secret.age".publicKeys = users ++ systems;
  "api-key.age".publicKeys = users ++ systems;
  
  # Host-specific secrets (only accessible by specific host)
  "example-nixos-secret.age".publicKeys = users ++ [ example-nixos ];
  "example-darwin-secret.age".publicKeys = users ++ [ example-darwin ];
}
