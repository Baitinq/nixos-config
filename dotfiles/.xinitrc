#!/bin/sh

export LC_CTYPE="en_US.UTF-8"
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

  # Preferred resolution + refresh rate
  RES="3440x1440"
  RATE="160.00"

  # Find a connected display (DP-2, HDMI-0, etc.)
  OUTPUT="$(xrandr | grep " connected" | cut -d' ' -f1)"

  # Only switch if the mode exists
  if xrandr | grep -qE "${RES}"; then
    xrandr --output "$OUTPUT" --mode "$RES" --rate "$RATE"
  else
    # For PRIME / hybrid setups
    xrandr --setprovideroutputsource modesetting NVIDIA-0
   fi
fi

# NEEDED FOR CHROMEBOOK
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

# CREATE SRC DEV FOLDER IF IT DOESNT EXIST
if [[ ! -d ~/src ]]; then
  mkdir ~/src
fi

xrandr --auto
#xrandr -s 1920x1080 &

xsetroot -cursor_name left_ptr

sxhkd &
clipmenud &
unclutter &
redshift -l $LOCATION &
numlockx on

systemctl --user start graphical-session.target

dunst &
habla &

dwmbar &

if lsusb --verbose 2>&1 | grep --quiet "Mouse"; then
        synclient TouchPadOff="1"
fi

while :; do ssh-agent smart-wallpaper -d ~/Images/Wallpapers/Day -n ~/Images/Wallpapers/Night -l $LOCATION -r; done &

exec xmonad 2> /tmp/xmonad.log
#exec dwm 2> /tmp/dwm.log

