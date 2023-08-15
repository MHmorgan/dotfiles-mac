
#DOC> reminders [-a] [NAME] :: Look for reminders in comments of source files :: INFO
function reminders {
    if [[ "$1" == '-a' ]]; then
        for DIR in $GOTO_DIRS; do
            header ${DIR//$HOME/\~}
            reminders $DIR
        done
        return 0
    fi

    local RE='(\s*(@\w+|\b(TODO|FIXME|BUG)\b))+'
    local DIR=${1:-.}

    # Expand goto directory if $1 is an exact match
    if (( $# > 0 )) && [[ ! -d $1 ]]; then
        local TMP
        for TMP in $GOTO_DIRS; do
            if [[ $1 == ${TMP##*/} ]]; then
                DIR=$TMP
                break
            fi
        done
    fi

    test -d $DIR || { err "not a directory: $DIR"; return 1 }
    local ARGS="-E $DIR -type f -maxdepth 13"
    find ${=ARGS} -regex ".*\.(c|go|java|kt|rs)$" |
        xargs rg --trim "//$RE"
    find ${=ARGS} -regex ".*\.(js|lua|pl|py|ts|zsh)$" |
        grep -v '/venv/' |
        xargs rg --trim "#$RE"
}

export __REMINDERS_HELP='usage: reminders [-a] [NAME]

Look for reminders in comments of source files.

The current directory is searched unless NAME is given.
NAME must be a name of a goto directory, or a directory path.

Options:
    -a  Search through all the directories in GOTO_DIRS.
'

