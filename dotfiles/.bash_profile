# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . "$HOME/.bashrc"

# Start Wayland*
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    #export LIBVA_DRIVER_NAME=nvidia
    #export XDG_SESSION_TYPE=wayland
    #export XDG_CURRENT_DESKTOP=sway
    #export GBM_BACKEND=nvidia-drm
    #export __GLX_VENDOR_LIBRARY_NAME=nvidia
    #export WLR_NO_HARDWARE_CURSORS=1
    #export GDK_BACKEND=nvidia
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export MOZ_ENABLE_WAYLAND=1
    export LIBSEAT_BACKEND="logind"
    export NIXOS_OZONE_WL=1
    exec wayland-session sway --unsupported-gpu
fi

# StartX
if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    exec startx
fi
