
#DOC> doctor :: Do some sanity checks of the system :: ESSENTIALS
function doctor {

    # PATH

    for P in ${(s.:.)PATH}; do
        test -d $P || echo "PATH: $P not found"
    done

    echo "GIT: Updating $#GIT_REPOS git repos."
    echo "GOTO: There are $#GOTO_DIRS goto directories."
}

