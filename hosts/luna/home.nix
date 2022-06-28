{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
let
  dotfiles = ../../dotfiles;
in
{
  home.packages = with pkgs; [
    #minecraft
    #jetbrains.idea-community
    calibre
    qtcreator
    kcc
    custom.anime-downloader
    custom.adl
    custom.trackma
    custom.kindlegen
  ];

  programs.firefox.profiles.default.settings = {
    "media.ffmpeg.vaapi.enabled" = true; #Hardware acceleration
  };

  xdg.configFile = {
    "dwmbar/config".text = ''
      #!/bin/sh

      # What modules, in what order
      MODULES="weather wifi internet volume ram_perc cpuload cputemp battery date time"

      # Modules that require an active internet connection
      ONLINE_MODULES="weather internet"

      # Delay between showing the status bar
      DELAY="0.05"

      # Where the custom modules are stored
      CUSTOM_DIR="/home/$USER/.config/dwmbar/modules/custom/"

      # Separator between modules
      SEPARATOR=" | "

      # Padding at the end and beggining of the status bar
      RIGHT_PADDING=" "
      LEFT_PADDING=" "
    '';

    "sxhkd/sxhkdrc".text =
      builtins.readFile (dotfiles + "/sxhkd/dwm") +
      builtins.readFile (dotfiles + "/sxhkd/base") +
      ''
      
        #enter and leave game mode
        alt + shift + F11: ctrl + shift + F11 
          pkill -ALRM sxhkd

        # Make sxhkd reload its configuration files
        alt + Escape
          pkill -USR1 -x sxhkd

        #Screenshot
        alt + grave
          bash ~/.scripts/screenshot

        #TODO: Print
        F5
          bash ~/.scripts/screenshot

        XF86Search
        	dmenu_run -i

        XF86PowerOff
        	bash ~/.scripts/exit

        #TODO: Change to XF86FullScreen or XF86XK_FullScreen when implemented
        F4
          dwmc togglefullscreen

        ##################
        ##### VOLUME #####
        ##################

        # Raise volume
        XF86AudioRaiseVolume
        	pactl set-sink-volume 0 +5%

        # Lower volume
        XF86AudioLowerVolume
        	pactl set-sink-volume 0 -5%

        # Mute audio
        # note: mute always sets audio off (toggle)
        XF86AudioMute
        	pactl set-sink-mute 0 toggle


        ######################
        ##### BRIGHTNESS #####
        ######################

        XF86MonBrightnessUp
          light -A 5

        XF86MonBrightnessDown
          light -U 5

        ######################
        ######## MEDIA #######
        ######################

        XF86AudioPlay
          playerctl play

        XF86AudioPause
          playerctl pause

        XF86AudioNext
          playerctl next

        XF86AudioPrev
          playerctl previous

        ######################
        ######## OTHER #######
        ######################

        @XF86Back
            xte 'keydown Alt_L' 'key Left' 'keyup Alt_L'

        @XF86Forward
            xte 'keydown Alt_L' 'key Right' 'keyup Alt_L'

        @XF86Reload
            xte 'keydown Control_L' 'key r' 'keyup Control_L'
      '';

    "mpv/mpv.conf".text = ''
      ytdl-format=bestvideo[height<=?720][fps<=?60][vcodec!=?vp9]+bestaudio/best
      hwdec
    '';
  };

  home.file.".cache/nix-index/files".source = inputs.nix-index.legacyPackages.x86_64-linux.database;
}
