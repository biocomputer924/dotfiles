main() {
    setopt hist_ignore_all_dups
    setopt hist_ignore_dups
    setopt hist_save_no_dups

    autoload -U compinit
    autoload -U promptinit
    autoload history-search-end

    export GREP_COLOR="7"
    export no_proxy="localhost"
    export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

    HISTFILE=$HOME"/.zsh_history"
    HISTSIZE=1000
    SAVEHIST=1000
    PS1="> "
    PS2=""

    alias echo="echo -e"
    alias grep="grep --color=auto"
    alias ls=$(which gls > /dev/null && echo gls || echo ls)" -Fl --group-directories-first --time-style=\"+"$(cursor_backward 1)"\""

    compinit
    promptinit

    zstyle ":completion:*" menu select 1

    zle -N history-beginning-search-backward-end history-search-end
    zle -N history-beginning-search-forward-end history-search-end

    bindkey "\e[A" history-beginning-search-backward-end
    bindkey "\e[B" history-beginning-search-forward-end

    source /usr/share/nvm/init-nvm.sh

    chpwd

    setopt NO_MONITOR
    hist &
}

hist() {
    tmp_history=$(except_duplicate < $HISTFILE)

    cat > $HISTFILE << A &
$tmp_history
A
}

chpwd() {
    precmd() {
        echo_header
        cursor_style 5

        precmd() {
            cursor_up 1
        }
    }
}

precmd() {
}

preexec() {
    echo

    precmd() {
        echo
        cursor_style 5

        precmd() {
            cursor_up 1
        }
    }
}

echo_header() {
    select_graphic_rendition "0;7"

    echo " "$USER"@"$HOST":"$PWD" "

    select_graphic_rendition "0"
}

echo_esc() {
    echo -n "\x1b"
}

echo_csi() {
    echo -n $(echo_esc)"["
}

cursor_forward() {
    echo -n $(echo_csi)$1"C"
}

cursor_backward() {
    echo -n $(echo_csi)$1"D"
}

cursor_up() {
    echo -n $(echo_csi)$1"A"
}

cursor_down() {
    echo -n $(echo_csi)$1"B"
}

if [ $TERM = "linux" ]
then
    cursor_style() {
        false
    }
else
    cursor_style() {
        echo -n $(echo_csi)$1" q"
    }
fi

select_graphic_rendition() {
    echo -n $(echo_csi)"$@""m"
}

except_duplicate() {
    entries=$(cat)

    rest=$(
        sed "s/^/ /" << A
$entries
A
    )

    while read -r a
    do
        rest=$(
            {read -r _; cat} << A
$rest
A
        )

        if ! grep -F -q -x " $a" << A
$rest
A
        then
            cat << A
$a
A
        fi
    done << A
$entries
A
}

main
