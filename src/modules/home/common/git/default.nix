{...}: {
  programs.git = {
    enable = true;
    settings.user.name = "Adam Paterson";
    settings.user.email = "hello@adampaterson.co.uk";
    settings.user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1CJVWAx5tlEl1onIshZURohd68JMza5uk1E+eStOUn";
  };
}
