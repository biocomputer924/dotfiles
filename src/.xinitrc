#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]
then
    for f in /etc/X11/xinit/xinitrc.d/?*
    do
        [ -x "$f" ] && . "$f"
    done

    unset f
fi

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export DefaultIMModule=fcitx

{
    while read f
    do
        $f </dev/null 1>/dev/null 2>&1 &
    done << EOF
fcitx
setxkbmap -option ctrl:nocaps
xbindkeys -f $HOME/.config/xbindkeys/.xbindkeysrc
statusbar
xrdb -merge $HOME/.config/X11/xinit/.Xresources
xsetroot -solid #404040
EOF
}

exec spectrwm 2>&1 | logger
