# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . "$HOME/.bashrc"

# StartX
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
fi
