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
      qemu
      redshift
      xwinwrap
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
      feh
      pavucontrol
      polkit_gnome
      progress
      qbittorrent
      xorg.xev
      statix
      nixpkgs-fmt
      openjdk8
      virt-manager
      xdotool #needed for xmobar clickable workspaces
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
    };

    direnv.enable = true;

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
        bypass-paywalls-clean
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

    obs-studio = { enable = true; };

    bash = {
      enable = true;
      bashrcExtra = builtins.readFile (dotfiles + "/.bashrc");
      profileExtra = builtins.readFile (dotfiles + "/.bash_profile");
    };

    zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [
          {
            name = "zsh-users/zsh-autosuggestions";
          } # Simple plugin installation
          {
            name = "zsh-users/zsh-syntax-highlighting";
          } # Simple plugin installation
          { name = "chrissicool/zsh-256color"; } # Simple plugin installation
          {
            name = "fsegouin/oh-my-zsh-agnoster-mod-theme";
            tags = [ "as:theme" "depth:1" ];
          } # Installations with additional options. For the list of options, please refer to Zplug README.
        ];
      };
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
    "./Images/Wallpapers".source = pkgs.fetchFromGitHub {
      owner = "Baitinq";
      repo = "Wallpapers";
      rev = "291f9a4cf78a6ad862da151139ea026ea72968e5";
      sha256 = "sha256-YKpIno5QSJM/GGp5DwQeuhKmTU5S96+IhLr0O0V8PDI=";
    };
  };

  # For disabling the automatic creation of $HOME/Desktop
  xdg.userDirs.desktop = "$HOME/";

  home.stateVersion = "22.05";
}
