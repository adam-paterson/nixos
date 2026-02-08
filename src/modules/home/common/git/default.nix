{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = lib.mkMerge [
      {
        user = {
          name = "Adam Paterson";
          email = "hello@adampaterson.co.uk";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1CJVWAx5tlEl1onIshZURohd68JMza5uk1E+eStOUn";
        };
      }
      (lib.mkIf pkgs.stdenv.isDarwin {
        gpg.format = "ssh";
        gpg.ssh.program = "${config.home.homeDirectory}/.local/bin/op-ssh-sign";
      })
    ];
  };
}
