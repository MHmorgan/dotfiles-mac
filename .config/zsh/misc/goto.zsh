
#DOC> goto STR... :: Goto a matching directory on the system [NAVIGATION]
function goto {
    if ! exists gum; then 
        err "'gum' not installed."
        return 1
    fi
    if (( $# == 0 )); then
        err 'Need some input...'
        return 1
    fi

    # SEARCH

    local DIR
    local -a DIRS=(${(s.:.)GOTO_PATH})  # Split on :
    local -a FILTERS=(-name "*$1*")
    test -n "$2" && FILTERS+=(-and -name "*$2*")
    test -n "$3" && FILTERS+=(-and -name "*$3*")

    local -a TARGETS
    for DIR in $(find $DIRS -type d -maxdepth 1 -mindepth 1 -and $FILTERS) 
    do
        # An exact match wins
        if (( $# == 1 )) && [[ $1 == ${DIR##*/} ]]; then
            TARGETS=($DIR)
            break
        fi
        TARGETS+=($DIR)
    done

    # SELECT

    if (( ${#TARGETS} <= 1 )); then
        DIR=$TARGETS
    else
        DIR=$(gum choose --header='Where to goto?' $TARGETS)
    fi
    if ! [[ -n "$DIR" ]]; then
        err "Nowhere to go :("
        return 1
    fi

    echo $DIR
    # -P use the physical directory structure instead of following symbolic links
    cd -P $DIR
    ls
}

