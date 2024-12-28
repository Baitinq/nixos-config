{ config, lib, pkgs, inputs, user, hostname, secrets, dotfiles, location, stateVersion, ... }:
{
  imports = [
    ../modules/email
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      scrot
      redshift
      discord
      tdesktop
      mpv
      sxiv
      #dwm
      #st
      alacritty
      # ghostty
      dmenu
      unclutter
      clipmenu
      dunst
      sxhkd
      zathura
      feh
      pavucontrol
      polkit_gnome
      nixpkgs-fmt
      virt-manager
      xmonadctl
      xdotool #needed for xmobar clickable workspaces
      xlockmore
      arandr
      # jrnl
      # todo-txt-cli
      # element-desktop
      speedtest-cli
      libnotify
      dwmbar
      manga-cli
      mov-cli
      calibre
      kcc
      slack
      openvpn
      smart-wallpaper
      waybar
      wl-clipboard
      sway
      swayidle
      swaylock-effects
      swaybg
      river
      wlr-randr
      wlsunset
      vscode
      chromium
      grim
      qbittorrent
      slurp
      appimage-run
      google-cloud-sdk
      ghidra
      ollama
      kubectl
      kubectx
      kubernetes-helm
    ] ++
    (with pkgs.custom; [
      lemacs
      kindlegen
    ]);
  };

  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = "${dotfiles}/xmonad.hs";
  };

  programs = {
    password-store = {
      enable = true;
      settings = {
        "PASSWORD_STORE_KEY" = "18BE4F736F27FC190C1E1000BB3C0BC698650937";
      };
    };
    ncmpcpp = {
      enable = true;
    };
    xmobar = {
      enable = true;
      extraConfig = builtins.readFile "${dotfiles}/xmobar.hs";
    };
  };

  home.sessionVariables = {
    LOCATION = "${location}";
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      sshKeys = [ "BC10A40920B576F641480795B9C7E01A4E47DA9F" ];
      defaultCacheTtl = 43200; #12h
      defaultCacheTtlSsh = 43200;
      maxCacheTtl = 86400; #24h
      maxCacheTtlSsh = 86400;
    };

    emacs = {
      enable = false;
      startWithUserSession = true;
    };

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xlockmore}/bin/xlock +resetsaver -dpmsoff 5 -mode blank";
      xautolock.enable = false;
    };

    mpd = {
      enable = true;
    };
  };

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "Baitinq";
      userEmail = "manuelpalenzuelamerino@gmail.com";
      signing = {
        signByDefault = true;
        key = "18BE4F736F27FC190C1E1000BB3C0BC698650937";
      };
      aliases = {
        pr = "!f() { git fetch -fu \${2:-origin} refs/pull/$1/head:pr/$1 && git checkout pr/$1; }; f";
      };
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "master";
        safe.directory = [ "*" ];
        sendemail = {
          smtpserver = "smtp.gmail.com";
          smtpserverport = "587";
          smtpencryption = "tls";
          smtpuser = "manuelpalenzuelamerino@gmail.com";
          smtpPass = secrets.email."manuelpalenzuelamerino@gmail.com".password;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        direnv
        which-key

        evil
        evil-collection

        general

        doom-modeline
        doom-themes
        dashboard

        projectile

        corfu
        kind-icon
        eldoc-box

        vertico
        consult
        orderless
        marginalia

        treesit-auto

        go-mode
        gotest
        rustic

        treemacs
        minimap
        centaur-tabs

        shell-pop
        eat
      ];
      extraConfig = builtins.readFile "${dotfiles}/.emacs";
    };

    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          darkreader
          h264ify
        ];
        extraConfig = lib.strings.concatStrings [
          (builtins.readFile "${inputs.arkenfox-userjs}/user.js")
          ''
	    // Re-enables URL usages as a search bar.
            /* 0801 */ user_pref("keyword.enabled", true);
	    user_pref("browser.search.suggest.enabled", true);    // 0804: live search suggestions
	    // Re-allows COPY / CUT from "non-privileged" content as it actually breaks many websites.
            /* 2404 */ user_pref("dom.allow_cut_copy", true);
            // Disables RFP letter-boxing to avoid big white borders on screen.
            /* 4504 */ user_pref("privacy.resistFingerprinting.letterboxing", false);
	    // Set UI density to normal
            user_pref("browser.uidensity", 0);
            // DRM content :(
            user_pref("media.gmp-widevinecdm.enabled", true);
            user_pref("media.eme.enabled", true);
	    user_pref("webgl.disabled", false); // 4520
            user_pref("network.http.referer.XOriginTrimmingPolicy", 0);
	    user_pref("privacy.clearOnShutdown.history", false); // 2811: don't clear history on close
	    user_pref("browser.startup.page", 3);                 // 0102: enable session restore
	    user_pref("signon.rememberSignons", true);           // 5003: enable saving passwords
	    /* [UX,-HIST] Remember more closed tabs for undo. */
            user_pref("browser.sessionstore.max_tabs_undo", 27);                    // 1020
            /* [UX,-HIST] Restore all state for closed tab or previous session after Firefox restart. */
            user_pref("browser.sessionstore.privacy_level", 0);                     // 1021
            user_pref("browser.sessionstore.interval", 15000);                      // 1023
            /* [UX,-HIST] Enable search and form history. */
            user_pref("browser.formfill.enable", true);                             // 0860
            user_pref("general.autoScroll", true);
	    //user_pref("network.cookie.lifetimePolicy", 0); //keep cookies 2801
	    user_pref("network.cookie.cookieBehavior", 5); // 2701
	    user_pref("privacy.clearOnShutdown.offlineApps", false);
            user_pref("privacy.cpd.offlineApps", false);
	    user_pref("privacy.cpd.history", false); // 2812 to match when you use Ctrl-Shift-Del
	    user_pref("privacy.clearOnShutdown.cookies", false);
	    user_pref("privacy.clearOnShutdown.downloads", false);
	    user_pref("privacy.clearOnShutdown.formdata", false);
	    user_pref("privacy.clearOnShutdown.sessions", false);
	    user_pref("extensions.pocket.enabled", false);        // 0900: disable Pocket
	    user_pref("_user.js.baitinq", "Survived the overrides :)");
	  ''
        ];
      };
    };

    rtorrent = { enable = true; };

    obs-studio = { enable = true; };

    bash = {
      enable = true;
      bashrcExtra = builtins.readFile "${dotfiles}/.bashrc";
      profileExtra = builtins.readFile "${dotfiles}/.bash_profile";
    };

    zsh = {
      enable = true;

      oh-my-zsh.enable = true;

      plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.fetchFromGitHub {
            owner = "jeffreytse";
            repo = "zsh-vi-mode";
            rev = "v0.11.0";
            sha256 = "sha256-xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
          };
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }
        {
          name = "zsh-256color";
          src = pkgs.fetchFromGitHub {
            owner = "chrissicool";
            repo = "zsh-256color";
            rev = "9d8fa1015dfa895f2258c2efc668bc7012f06da6";
            sha256 = "sha256-Qd9pjDSQk+kz++/UjGVbM4AhAklc1xSTimLQXxN57pI=";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.7.0";
            sha256 = "sha256-eRTk0o35QbPB9kOIV0iDwd0j5P/yewFFISVS/iEfP2g=";
          };
        }
        {
          name = "agnoster-nanof";
          file = "agnoster-nanof.zsh-theme";
          src = pkgs.fetchFromGitHub {
            owner = "fsegouin";
            repo = "oh-my-zsh-agnoster-mod-theme";
            rev = "46832da7156a4cd67e9b7ed245bb2782c690b8bb";
            sha256 = "sha256-hCG/N0AbjAxDLbMo+lLpf6SKyx5Athru84nWL/3spb4=";
          };
        }
      ];

      shellAliases = {
        ls = "ls --color";
        l = "ls -l";
        ll = "ls -la";
        weather = "(){ curl -s v2.wttr.in/$1 }";
        vim = "nvim";
        q = "exit";
        c = "clear";
        open = "xdg-open";
        k = "kubectl";
        bzl = "bazel";
        extract = ''
          () {
            if [ -f $1 ] ; then
              case $1 in
                *.tar.bz2)   tar xvjf $1    ;;
                *.tar.gz)    tar xvzf $1    ;;
                *.tar.xz)    tar Jxvf $1    ;;
                *.bz2)       bunzip2 $1     ;;
                *.rar)       rar x $1       ;;
                *.gz)        gunzip $1      ;;
                *.tar)       tar xvf $1     ;;
                *.tbz2)      tar xvjf $1    ;;
                *.tgz)       tar xvzf $1    ;;
                *.zip)       unzip -d `echo $1 | sed 's/\(.*\)\.zip/\1/'` $1;;
                *.Z)         uncompress $1  ;;
                *.7z)        7z x $1        ;;
                *)           echo "don't know how to extract '$1'" ;;
              esac
            else
              echo "'$1' is not a valid file!"
            fi
          }'';
      };

      initExtra = ''
        autoload -U history-search-end #needed for -end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end

        #when going up go up only beggining of curr word history
        bindkey '\e[A' history-beginning-search-backward-end
        bindkey '\e[B' history-beginning-search-forward-end
        #ctrl + arrow forward/backward word
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        #alt + arrow forward/backward word
        bindkey "^[[1;3C" forward-word
        bindkey "^[[1;3D" backward-word
        #alt + delete delete whole word
        bindkey "\e\x7f" backward-kill-word
      '';
    };

  };

  xdg = {
    configFile."tmux/tmux.conf".source = "${dotfiles}/tmux.conf";
    configFile."nvim/".source = "${dotfiles}/nvim/";
    configFile."alacritty/alacritty.toml".source = "${dotfiles}/alacritty.toml";
    configFile."sway/config".source = "${dotfiles}/sway_config";
    configFile."river/".source = "${dotfiles}/river/";
    configFile."waybar/".source = "${dotfiles}/waybar/";
    configFile."zathura/zathurarc".source = "${dotfiles}/zathurarc";
    configFile."dunst/dunstrc".source = "${dotfiles}/dunstrc";
  };

  home.file = {
    ".xinitrc".source = "${dotfiles}/.xinitrc";
    ".Xresources".source = "${dotfiles}/.Xresources";

    ".scripts/".source = "${dotfiles}/scripts/";

    ".netrc".text = secrets.netrc;
  };

  home.file = {
    ".tmux/plugins/tpm".source = inputs.tpm;
    "./Images/Wallpapers".source = inputs.wallpapers;
  };

  home.sessionPath = [
    "/home/${user}/.cargo/bin"
  ];

  fonts.fontconfig.enable = true;

  # For disabling the automatic creation of $HOME/Desktop
  xdg.userDirs.desktop = "$HOME/";

  home.stateVersion = stateVersion;

}
