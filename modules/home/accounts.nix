{
  accounts = {
    email = {
      maildirBasePath = "Maildir"; # default
      accounts = {
        Gmail = {
          enable = true;
          primary = true;
          mu.enable = true;
          msmtp.enable = true;
          flavor = "gmail.com";
          # passwordCommand = "pass gmail";
          realName = "Robert Babaev";
          smtp.host = "smtp.gmail.com"; # TODO: Figure out wtf proton uses
          address = "github@robertbabaev.tech";
          userName = "github@robertbabaev.tech";
          signature = {
            text = ''
              Best,
              Robert Babaev
            '';
            showSignature = "append";
          };

          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            patterns = ["*" "[Gmail]*"]; # "[Gmail]/Sent Mail" ];
          };

          # imap={
          #  port = 993;
          #  tls.enable = true;
          #  host = "imap.gmail.com";
          # };

          # smtp = {
          #  port = 587;
          #   tls.useStartTls = true;
          #   host = "smtp.gmail.com";
          # };
        };
      };
    };

    calendar = {
      accounts = {
        ender = {
          khal = {
            enable = true;
          };
          qcal.enable = true;
        };
      };
    };

    contact = {
      # basePath = "";
      accounts = {
        ender = {
          khard.enable = false;
          local = {
            type = "filesystem";
          };
          remote = {
            userName = "ender";
            url = "";
            type = "carddav"; # http google_contacts
          };
        };
      };
    };
  };
}
