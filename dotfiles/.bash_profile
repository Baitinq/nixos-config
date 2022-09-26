# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . "$HOME/.bashrc"

# Start River
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export MOZ_ENABLE_WAYLAND=1
    exec river
fi

# StartX
if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    exec startx
fi
