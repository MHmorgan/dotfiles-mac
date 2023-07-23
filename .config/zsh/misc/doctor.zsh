
#DOC> doctor :: Do some sanity checks of the system [CORE]
function doctor {
    for P in ${(s.:.)PATH}; do
        test -d $P || echo "PATH: $P not found"
    done
}

