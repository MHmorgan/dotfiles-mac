
#DOC> boilerplate [NAME] :: Print a boilerplate or list boilerplates.
function boilerplate {
    if (( $# == 0 )); then
        ls ~/.config/zsh/boilerplates
        return 0
    fi

    local FILE="$HOME/.config/zsh/boilerplates/$1"
    [[ -f $FILE ]] || { err "Unknown boilerplate: $NAME"; return 1 }
    cat $FILE
}
