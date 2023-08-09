
#DOC> goto <arg> :: Goto a matching directory on the system :: NAVIGATION
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

    local -a TARGETS
    for DIR in $GOTO_DIRS; do
        # An exact match wins
        if [[ $1 == ${DIR##*/} ]]; then
            TARGETS=($DIR)
            break
        fi
        [[ ${DIR##*/} =~ $1 ]] && TARGETS+=($DIR)
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

__GOTO_HELP='Usage: goto <arg>

Go to a directory specified by arg.
The string may be either an exact match or a substring of
a directory name in the GOTO_DIRS.
'

#DOC> gotor [args...] :: Go to a directory relative to cwd :: NAVIGATION
function gotor {
    local TARGETS=( $(find . -type d | grep "$1" | grep "$2" | grep "$3" | grep "$4" ) )
    
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
    cd $DIR
    ls
}

__GOTOR_HELP='Usage: gotor [args...]

Select a directory, relative to cwd, to go to.
The args can be used to filter targets (max 4 filters).
'

