_: rec {
  emails = {
    personal = "hello@adampaterson.co.uk";
    work = "adam.paterson@idhl.co.uk";
    business = "adam@thrivegroup.ai";
  };

  user = {
    name = "Adam Paterson";
    email = emails.personal;
  };

  git = {
    profiles = [
      {
        name = "default";
        userName = user.name;
        userEmail = emails.personal;
        signingKey = "";
      }
      {
        name = "work";
        userName = user.name;
        userEmail = emails.work;
        signingKey = "";
      }
      {
        name = "business";
        userName = user.name;
        userEmail = emails.business;
        signingKey = "";
      }
    ];
  };

  theme = {
    palette = {
      os = "#ACB0BE";
      pink = "#F5BDE6";
      lavender = "#B7BDF8";
      blue = "#8AADF4";
      white = "#FFFFFF";
      text = "#494D64";
    };
  };
}
