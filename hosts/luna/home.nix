{ config, lib, pkgs, inputs, user, hostname, location, secrets, dotfiles, ... }:
{
  home.packages = with pkgs; [
    xorg.xmodmap
    trackma
    adl
  ] ++
  (with pkgs.custom; [
  ]);

  programs.firefox.profiles.default.settings = {
    "gfx.webrender.all" = true;
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
      builtins.readFile "${dotfiles}/sxhkd/xmonad" +
      builtins.readFile "${dotfiles}/sxhkd/base" +
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

        Print
          bash ~/.scripts/screenshot

        XF86Search
        	dmenu_run -i

        #TODO: should be XF86FullScreen (idk why it doesnt work with nixos xorg)
        F4
          dwmc togglefullscreen

        XF86PowerOff
        	bash ~/.scripts/exit

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

  home.file.".Xmodmap".text = ''
    ! bind F1 and F2 to back and forward
    ! Use Shift+F1 or Shift+F2 to use F1 and F2 actions, e.g. rename a file
    keycode  67 = XF86Back F1 F1 F1 F1 F1 XF86Switch_VT_1
    keycode  68 = XF86Forward F2 F2 F2 F2 F2 XF86Switch_VT_2

    ! bind F3 to refresh
    keycode  69 = XF86Refresh F3 F3 F3 F3 F3 XF86Switch_VT_3

    ! TODO: bind F4 to fullscreen (when supported nixos xorg)
    ! keycode  70 = XF86FullScreen F4 F4 F4 F4 F4 XF86Switch_VT_4

    ! bind F5 to print
    keycode  71 = Print F5 F5 F5 F5 F5 XF86Switch_VT_5

    ! bind F6, F7 to brightness down and up
    keycode  72 = XF86MonBrightnessDown F6 F6 F6 F6 F6 XF86Switch_VT_6
    keycode  73 = XF86MonBrightnessUp F7 F7 F7 F7 F7 XF86Switch_VT_7

    ! bind F8, F9, F10 to mute, voldown, volup
    keycode  74 = XF86AudioMute F8 F8 F8 F8 F8 XF86Switch_VT_8
    keycode  75 = XF86AudioLowerVolume F9 F9 F9 F9 F9 XF86Switch_VT_9
    keycode  76 = XF86AudioRaiseVolume F10 F10 F10 F10 F10 XF86Switch_VT_10

    ! bind Super+L to search
    keycode  133 = XF86Search
  '';

}
