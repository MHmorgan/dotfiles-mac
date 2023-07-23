

#DOC> gsync :: Synchronize current git repo [GIT]
function gsync {
    # Commit a dirty repo
    if git-is-dirty
    then
        git status --untracked-files=no 
        gum confirm 'Commit changes?' || return 1

        git commit -av ||
        gum confirm 'Continue sync?' ||
        return 1
    fi

    git pull --rebase &&
    git push
}

#DOC> root :: Go to the root dir of current repo [GIT]
function root {
    local DIR=$PWD
    while [[ -n "$DIR" ]]; do
        test -e $DIR/.git && break
        DIR=${DIR%/*}
    done

    if [[ -z "$DIR" ]]; then
        err "Not in a git repo"
        return 1
    fi

    echo $DIR
    cd $DIR
    ll
}

#DOC> st :: Show git and gh status [GIT]
function st {
    gh status

    if git-in-repo; then
        # Status of current repo
        bold "Repo: ${$(git-root)##*/}"
        git status --show-stash
    else
        # Or, show status of unclean repos
        for DIR in $GIT_REPOS; do
            if ! [[ -d $DIR ]]; then
                err "Repo not found: $DIR"
                continue
            fi
            pushd -q $DIR
            if git-is-dirty; then
                bold ${DIR##*/}
                git status --short --show-stash
                echo
            fi
            popd -q
        done
    fi
}

# ----------------------------------------------------------
# HELPERS

function git-is-dirty {
    test -n "$(git status --untracked-files=no --porcelain)"
}

function git-has-updates {
    git remote update || return 0

    # https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
    local UPSTREAM=${1:-'@{u}'}
    local REMOTE=$(git rev-parse "$UPSTREAM")
    local BASE=$(git merge-base @ "$UPSTREAM")

    [[ $REMOTE != $BASE ]]
}

function git-in-repo {
    git show-branch &>/dev/null
}

function git-root {
    local DIR=$PWD
    while test -n "$DIR"; do
        if test -e $DIR/.git; then
            echo $DIR
            return
        fi
        DIR=${DIR%/*}
    done
    return 1
}

function git-repo-name {
    local DIR=$PWD
    while test -n "$DIR"; do
        if test -e $DIR/.git; then
            echo ${DIR##*/}
            return
        fi
        DIR=${DIR%/*}
    done
    return 1
}
