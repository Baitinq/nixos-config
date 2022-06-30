#!/bin/sh

export LC_CTYPE="en_US.UTF-8"
export LOCATION="52.954784:-1.158109"
export _JAVA_AWT_WM_NONREPARENTING=1

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

#NEEDED
if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
	eval $(dbus-launch --exit-with-session --sh-syntax)
fi
systemctl --user import-environment DISPLAY XAUTHORITY

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        dbus-update-activation-environment DISPLAY XAUTHORITY
fi

# NEEDED FOR NVIDIA DRIVERS
if [ -x "$(command -v nvidia-smi)" ]; then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
fi

# NEEDED FOR CHROMEBOOK
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

# CREATE SRC DEV FOLDER IF IT DOESNT EXIST
if [[ ! -d ~/src ]]; then
  mkdir ~/src
fi

xrandr --auto
#xrandr -s 1920x1080 &

sxhkd &
clipmenud &
unclutter &
redshift &
numlockx on

systemctl --user start graphical-session.target

dunst &

dwmbar &

while :; do ssh-agent smart-wallpaper -d ~/Images/Wallpapers/Day -n ~/Images/Wallpapers/Night -r; done &

exec dwm 2> /tmp/dwm.log

