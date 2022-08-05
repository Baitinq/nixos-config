{ config, lib, pkgs, inputs, user, hostname, secrets, location, ... }:
let
  dotfiles = ../dotfiles;
in
{
  imports = [ ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      scrot
      redshift
      discord
      mpv
      sxiv
      #dwm
      st
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
      xdotool #needed for xmobar clickable workspaces
      xlockmore
      arandr
    ] ++
    (with pkgs.custom; [
      smart-wallpaper
      dwmbar
      xmonadctl
      lemacs
    ]);
  };

  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = dotfiles + "/xmonad.hs";
  };

  programs.xmobar = {
    enable = true;
    extraConfig = builtins.readFile (dotfiles + "/xmobar.hs");
  };

  home.sessionVariables = {
    LOCATION = "${location}";
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      sshKeys = [ "BC10A40920B576F641480795B9C7E01A4E47DA9F" ];
      defaultCacheTtl = 43200; #12h
      defaultCacheTtlSsh = 43200;
      maxCacheTtl = 86400; #24h
      maxCacheTtlSsh = 86400;
    };

    emacs = {
      enable = true;
      startWithUserSession = true;
    };

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xlockmore}/bin/xlock -mode blank";
      xautolock.enable = false;
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "Baitinq";
      userEmail = "manuelpalenzuelamerino@gmail.com";
      signing = {
        signByDefault = true;
        key = "18BE4F736F27FC190C1E1000BB3C0BC698650937";
      };
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "master";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        use-package

        direnv

        evil
        evil-collection

        doom-modeline
        dashboard

        lsp-ui
        projectile

        lsp-mode
        company
        lsp-haskell

        nix-mode
        haskell-mode
        typescript-mode
        jq-mode

        doom-themes
      ];
      extraConfig = builtins.readFile (dotfiles + "/.emacs");
    };

    firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        https-everywhere
        h264ify
      ];
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = {
          "general.autoScroll" = true;
        };
      };
    };

    rtorrent = { enable = true; };

    obs-studio = { enable = true; };

    bash = {
      enable = true;
      bashrcExtra = builtins.readFile (dotfiles + "/.bashrc");
      profileExtra = builtins.readFile (dotfiles + "/.bash_profile");
    };

    zsh = {
      enable = true;

      oh-my-zsh.enable = true;

      plugins = [
        {
          # will source zsh-autosuggestions.plugin.zsh
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
    configFile."zathura/zathurarc".source = dotfiles + "/zathurarc";
    configFile."dunst/dunstrc".source = dotfiles + "/dunstrc";
  };

  home.file = {
    ".xinitrc".source = dotfiles + "/.xinitrc";
    ".Xresources".source = dotfiles + "/.Xresources/";

    ".scripts/".source = dotfiles + "/scripts/";
  };

  home.file = {
    "./Images/Wallpapers".source = inputs.wallpapers;
  };

  # For disabling the automatic creation of $HOME/Desktop
  xdg.userDirs.desktop = "$HOME/";

  home.stateVersion = "22.05";
}
