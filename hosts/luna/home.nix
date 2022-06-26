{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
{
  home.packages = with pkgs; [
    #minecraft
    #jetbrains.idea-community
    calibre
    qtcreator
    custom.anime-downloader
    custom.adl
    custom.trackma
    custom.kindlegen
    kcc
  ];

  #TODO: Can we just not update prev set?
  programs.firefox.profiles.default.settings = {
    "general.autoScroll" = true; #TODO: This is aready set in parent home
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

    "mpv/mpv.conf".text = ''
      ytdl-format=bestvideo[height<=?720][fps<=?60][vcodec!=?vp9]+bestaudio/best
      hwdec
    '';
  };
}
