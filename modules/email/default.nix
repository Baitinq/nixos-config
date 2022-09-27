{ config, pkgs, lib, secrets, ... }:
{
  services = {
    mbsync = {
      enable = true;
      postExec = "${pkgs.notmuch}/bin/notmuch new";
    };
    imapnotify.enable = false;
  };

  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
    notmuch.enable = true;
    neomutt = {
      enable = true;
      sidebar.enable = true;
      vimKeys = true;
      sort = "reverse-date";
    };
  };

  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      "manuelpalenzuelamerino@gmail.com" = {
        primary = true;
        flavor = "gmail.com";

        realName = "Manuel Palenzuela Merino";
        signature = {
          showSignature = "none";
          text = ''
            Manuel Palenzuela Merino
          '';
        };

        address = "manuelpalenzuelamerino@gmail.com";
        userName = "manuelpalenzuelamerino@gmail.com";

        imapnotify = {
          enable = true;
          boxes = [ "Inbox" ];
          onNotifyPost = {
            mail = ''
              ${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send "New mail arrived."
            '';
          };
        };
        msmtp.enable = true;
        notmuch.enable = true;
        mbsync = {
          enable = true;
          create = "both";
        };
        neomutt = {
          enable = true;
          /*extraConfig = ''
            set imap_user = 'manuelpalenzuelamerino@gmail.com'
            set imap_pass = '${secrets.email."manuelpalenzuelamerino@gmail.com".password}'
            set spoolfile = imaps://imap.gmail.com/INBOX
            set folder = imaps://imap.gmail.com/
            set record="imaps://imap.gmail.com/[Gmail]/Sent Mail"
            set postponed="imaps://imap.gmail.com/[Gmail]/Drafts"
            set mbox="imaps://imap.gmail.com/[Gmail]/All Mail"

            # ================  SMTP  ====================
            set smtp_url = "smtp://manuelpalenzuelamerino@smtp.gmail.com:587/"
            set smtp_pass = ${secrets.email."manuelpalenzuelamerino@gmail.com".password}
            set ssl_force_tls = yes # Require encrypted connection
          '';*/
        };
        passwordCommand = "${pkgs.coreutils}/bin/echo ${secrets.email."manuelpalenzuelamerino@gmail.com".password}";
      };
    };
  };
}

