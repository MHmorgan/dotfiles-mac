
#DOC> dls :: List all dotfiles :: DOTFILES
function dls {
    pushd -q $HOME
    dot ls-tree -r main | awk '{ print $4}' | xargs ls -l
    popd &>/dev/null
}

#DOC> dst :: Show dotfiles repo status :: DOTFILES
function dst {
    pushd -q $HOME
    dot status --show-stash
    popd -q
}

#DOC> ddiff :: Show dotfiles git diff :: DOTFILES
function ddiff {
    pushd -q $HOME
    dot diff
    popd -q
}

#DOC> dsync :: Synchronize the dotfiles repo :: DOTFILES
function dsync {
    pushd -q $HOME

    # Commit a dirty repo
    if dot-is-dirty
    then
        dot status
        gum confirm 'Add & commit changes?' || return 1

        # Update version for modified files
        local UPDATED_ZSHRC=false
        for FILE in $(dot status -uno --porcelain=v1 | awk '{ print $2 }')
        do
            [[ $FILE == ".zshrc" ]] && UPDATED_ZSHRC=true
            dot-increase-version $FILE
        done
        # Zshrc should always be updated, as its version number reflects the
        # version for the entire dotfile setup.
        $UPDATED_ZSHRC || dot-increase-version .zshrc

        dot add --all &&
        dot commit -v ||
        gum confirm 'Continue sync?' ||
        return 1
    fi

    dot pull --rebase &&
    dot push
    popd -q
}

export __DSYNC_HELP='Usage: dsync

Synchronize dotfiles: add all modifications and new files;
increment version numbers in files; create a commit and push.
'


#DOC> edit-?? [NAME...] :: Edit files of some kind. :: DOTFILES
function edit-dotfile {
    if (( $# == 0 )); then
        err "Missing dotfile(s)"
        return
    fi

    pushd -q $HOME
    $EDITOR -p $*  # Assumes a vi-like editor
    popd -q

    dot-is-dirty &&
    gum confirm 'Sync dotfiles?' &&
    dsync
}

function edit-nvim {
    pushd -q ~/.config/nvim
    if (( $# > 0 )); then
        $EDITOR -p $*
    else
        $EDITOR .
    fi
    popd -q

    dot-is-dirty &&
    gum confirm 'Sync dotfiles?' &&
    dsync
}

function edit-zsh {
    pushd -q ~/.config/zsh
    if (( $# > 0 )); then
        $EDITOR -p $*
    else
        $EDITOR .
    fi
    popd -q

    dot-is-dirty &&
    gum confirm 'Sync dotfiles?' &&
    dsync
}

# ----------------------------------------------------------
# HELPERS

function dot-increase-version {
    test -f $1 || return

    local OLD=$(cat $1 | perl -nE 'say $1 if /:: (v\d+) ::/')
    local TMP=/tmp/dotfiles/increase-version-file
    mkdir -p /tmp/dotfiles

    # Replace version like :: vN ::
    cat $1 | perl -pE '
        next unless /:: v(\d+) ::/;
        my $num = $1 + 1;
        $_ =~ s/$1/$num/;
    ' > $TMP &&
    mv $TMP $1

    local NEW=$(cat $1 | perl -nE 'say $1 if /:: (v\d+) ::/')
    if [[ "$OLD" != "$NEW" ]]; then
        echo "$1 $OLD -> $NEW"
    fi
}

function dot-is-dirty {
    test -n "$(dot status --porcelain)"
}

