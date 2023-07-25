
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

#DOC> boilerplate-m4 [NAME] :: Like `boilerplate`, but the content is passed through `m4`.
function boilerplate-m4 {
    boilerplate $* | m4
}

function edit-boilerplate {
    (( $# > 0 )) || { err "Missing boilerplate name."; return 1 }
    pushd -q ~/.config/zsh/boilerplates
    $EDITOR -p $*
    popd -q
}

