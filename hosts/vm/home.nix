{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
{
  home.packages = with pkgs; [
    #jetbrains.idea-community
    #qtcreator
  ];

  xdg.configFile."dwmbar/config".text = ''
    #!/bin/sh

    # What modules, in what order
    MODULES="weather wifi internet volume ram_perc cpuload cputemp date time"

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
}
