
#DOC> help [NAME] :: Print the global help or a help message :: INFO
function help {
    if (( $# == 0 )); then
        cat $HELP_FILES | python3 ~/.config/zsh/misc/help.py | glow
        return 0
    fi

    local VAR="__$(echo $1 | tr '[:lower:]' '[:upper:]')_HELP"
    eval "echo \${$VAR:-'Unknown help message: $1'}"
}

