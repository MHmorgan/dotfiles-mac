
#DOC> update :: Update the system
function update {
    neofetch

    #header 'Rogu'
    #rogu -v update

    header 'Dotfiles'
    dsync

    if (( ${#GIT_REPOS} == 0 )); then
        echo '\nGIT_REPOS is empty.'
    else
        header Repos
    fi
    for DIR in $GIT_REPOS; do
        NAME=${DIR##*/}

        if ! [[ -d $DIR ]]; then
            err "Repo not found: $DIR"
            continue
        fi

        pushd -q $DIR
        if git-is-dirty; then
            echo "Dirty: ${NAME}"
        else
            echo "Clean: ${NAME}"
            if git-has-updates; then
                gum confirm "Pull remote changes in ${NAME}?" &&
                git pull --rebase
            fi
        fi
        popd -q
    done

    header 'Homebrew'
    brew update && brew upgrade --quiet

    if exists go && (( $#GO_APPS > 0 ))
    then
        header 'Go Apps'
        for APP in $GO_APPS; do
            echo $APP
            go install $APP
        done
    else
        echo "\nGO_APPS is empty."
    fi

    if exists cargo && (( $#RUST_APPS > 0 ))
    then
        header 'Rust Apps'
        for APP in $RUST_APPS; do
            echo $APP
            cargo install $APP 2>&1 | egrep -v 'Updating|Ignored'
        done
    else
        echo "\nRUST_APPS is empty."
    fi
}

