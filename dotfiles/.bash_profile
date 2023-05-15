# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . "$HOME/.bashrc"

# Start River
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export MOZ_ENABLE_WAYLAND=1
    export LIBSEAT_BACKEND="logind"
    export NIXOS_OZONE_WL=1
    exec river
fi

# StartX
if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    exec startx
fi
