
#DOC> reminders [NAME] :: Look for reminders in comments of source files :: INFO
function reminders {
    local RE='(@\w+|\b(TODO|FIXME|BUG)\b)'
    local DIR=${1:-.}

    if (( $# > 0 )); then
        local TMP
        for TMP in $GOTO_DIRS; do
            if [[ $1 == ${TMP##*/} ]]; then
                DIR=$TMP
                break
            fi
        done
    fi

    test -d $DIR || { err "not a directory: $DIR"; return 1 }

    # Languages with // comments
    find -E $DIR -type f -regex ".*\.(go|java|kt|rs)$" | xargs rg "//.*$RE"

    # Languages with # comments
    find -E $DIR -type f -regex ".*\.(pl|py|zsh)$" | xargs rg "#.*$RE"
}

export __REMINDERS_HELP='usage: reminders [NAME]

Look for reminders in comments of source files.
'

