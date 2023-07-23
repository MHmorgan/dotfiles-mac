
#DOC> backup FILE... :: Create a backup of files
function backup {
    local src=$1

    if ! [[ -f "$src" ]]
    then
        echo "source file not found: $src"
        return 1
    fi

    cp -vpr $src $src~
}

function all_gum_spinners {
    for X in line dot minidot jump pulse points globe moon monkey meter hamburger; do
        gum spin --spinner=$X --title=$X sleep 5
    done
}

#DOC> makels :: List makefile targets
function makels {
    local FILE=${1:-Makefile}
    cat $FILE | egrep -o '^\w+:' | tr -d ':' | sort | column
}

