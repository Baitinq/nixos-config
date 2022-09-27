{ config, pkgs, lib, secrets, ... }:
{
  services = {
    mbsync.enable = true;
    imapnotify.enable = true;
  };

  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
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

        realName = "Manuel Palenzuela Merino";
        signature = {
          showSignature = "none";
          text = ''
            Manuel Palenzuela Merino
          '';
        };

        address = "manuelpalenzuelamerino@gmail.com";
        userName = "manuelpalenzuelamerino@gmail.com";

        imap = {
          host = "imap.gmail.com";
          port = 993;
        };

        smtp = {
          host = "smtp.gmail.com";
          port = 587;
        };

        imapnotify = {
          enable = true;
          boxes = [ "Inbox" ];
          onNotifyPost = ''
            ${pkgs.libnotify}/bin/notify-send "New mail arrived."
          '';
        };
        msmtp.enable = true;
        mbsync = {
          enable = true;
          create = "both";
        };
        neomutt = {
          enable = true;
          mailboxName = "Inbox";
          extraMailboxes = [
            "\[Gmail\]/Sent\ Mail"
            "\[Gmail\]/Bin"
            "\[Gmail\]/Starred"
            "\[Gmail\]/Drafts"
          ];
          extraConfig = ''
            set edit_headers = yes  # See the headers when editing
            set charset = UTF-8     # value of $LANG; also fallback for send_charset
            unset use_domain        # because joe@localhost is just embarrassing
            set use_from = yes
            set index_format='%4C %Z %<[y?%<[m?%<[d?%[%H:%M ]&%[%a %d]>&%[%b %d]>&%[%m/%y ]> %-15.15L (%?l?%4l&%4c?) %s'
          '';
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

