# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . "$HOME/.bashrc"

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
fi

# Start River
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec river
fi

# StartX
if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    exec startx
fi
