
#DOC> reminders [-a] [NAME] :: Look for reminders in comments of source files :: INFO
function reminders {
    # Search for reminders in all goto-directories
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


#DOC> reminder <TAG> :: Look for a specific reminder in comments of source files :: INFO
function reminder {
    # Search for a reminder in all goto-directories
    if [[ "$1" == '-a' ]]; then
        if (( $# < 2 )); then
            echo "ERROR: Missing argument(s). See 'help reminder'"
            return 1
        fi
        for DIR in $GOTO_DIRS; do
            header ${DIR//$HOME/\~}
            reminder $2 $DIR
        done
        return 0
    fi
    if (( $# < 1 )); then
        echo "ERROR: Missing argument(s). See 'help reminder'"
        return 1
    fi

    local DIR=${2:-.}

    # Expand goto directory if $2 is an exact match
    if (( $# > 1 )) && [[ ! -d $2 ]]; then
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
        xargs rg --trim "//.*$1"
    find ${=ARGS} -regex ".*\.(js|lua|pl|py|ts|zsh)$" |
        grep -v '/venv/' |
        xargs rg --trim "#.*$1"
}


export __REMINDER_HELP='usage: reminder [-a] <TAG> [NAME]

Look for a specific reminder in comments of source files,
defined by the TAG (e.g. @Todo).

The current directory is searched unless NAME is given.
NAME must be a name of a goto directory, or a directory path.

Options:
    -a  Search through all the directories in GOTO_DIRS.
'

