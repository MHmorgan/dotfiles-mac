# vim: filetype=zsh:tabstop=4:shiftwidth=4:expandtab:

echo "Zshrc Mac :: v169 ::"
echo "-> .zshrc"

# TODO Add `edit-rogu` which opens a file which is a Rogu resource

autoload -U colors && colors
function info   { echo "\e[${color[faint]};${color[default]}m$*$reset_color" }
function warn   { echo "WARN: $*" }
function err    { echo "ERROR: $*" }
function bold   { echo "$fg_bold[default]$*$reset_color" }
function exists { which $* &>/dev/null }
function header { gum style --border=rounded --width=20 --align=center --margin="1 0" "$*" }

alias ls="ls -FG"
alias la="ls -AFG"
alias ll="ls -Glh"
alias lla="ls -AGlh"
alias l1="ls -1FGh"

function help {
    help.py $* | glow
}

# ------------------------------------------------------------------------------
# VARIABLES

export EDITOR='nvim'
export PAGER='less'

# Paths for the help.py script
export HELP_PATH="$HOME/help-pages"

#DOC> HELP_FILES :: Paths for `help` to search (: separated) [VARIABLES]
export HELP_FILES="$HOME/.zshrc:$HOME/.vimrc:$HOME/.myzshrc"

#DOC> TODO_PATH :: Paths for the todo script (: separated) [VARIABLES]
export TODO_PATH="$HOME/Projects:$HOME/Documents"

#DOC> GOTO_PATH :: Paths for the goto command (: separated) [VARIABLES]
export GOTO_PATH="$HOME/bin:$HOME/Documents:$HOME/Downloads:$HOME/Projects"

#DOC> GO_APPS :: Zsh array of go applications for `update` [VARIABLES]
export GO_APPS=(
    github.com/mhmorgan/todo@latest
    github.com/mhmorgan/watch@latest
)

#DOC> RUST_APPS :: Zsh array of rust applications for `update` [VARIABLES]
export RUST_APPS=()

#DOC> HOMEBREW_APPS :: Essential Homebrew apps which should be installed [VARIABLES]
export HOMEBREW_APPS=(
    aspell
    cheat
    cmatrix
    cowsay
    figlet
    fortune
    gcc
    gdbm
    gh
    glow
    go
    gradle
    gum
    ipython
    jq
    kotlin
    lazygit
    neofetch
    neovim
    openjdk
    pandoc
    parallel
    plantuml
    python
    rust
    sl
    starship
    tldr
)

#DOC> GIT_REPOS :: Zsh array of repo directories for `update` [VARIABLES]
export GIT_REPOS=()

# PATH

export PATH="$HOME/bin:$HOME/Documents/scripts:$HOME/.local/bin:$PATH"

# Homebrew
if [[ -d /opt/homebrew ]]; then
    export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
elif [[ -d $HOME/homebrew ]]; then
    export PATH="$PATH:$HOME/homebrew/bin:$HOME/homebrew/sbin"
else
    err "Homebrew root folder not found."
fi

# Go
export PATH="$PATH:$HOME/go/bin"

# Rust
export PATH="$PATH:$HOME/.cargo/bin"


# ------------------------------------------------------------------------------
# GIT
#{{{

#DOC> lg :: Start lazygit [GIT]
alias lg='lazygit'

#DOC> glog :: Print the last 7 log entries [GIT]
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'

#DOC> glist :: List my non-archived GitHub repos [GIT]
alias glist='gh repo list --no-archived'

#DOC> gclone :: Clone a GitHub repo [GIT]
alias gclone='gh repo clone'

#DOC> gc :: Git commit alias [GIT]
alias gc='git commit --verbose'

#DOC> gca :: Git commit all alias [GIT]
alias gca='git commit --verbose --all'

#DOC> gst :: Git status alias [GIT]
alias gst='git status'

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

# GIT SCRIPTING HELPER FUNCTIONS

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

#}}}

# ------------------------------------------------------------------------------
# NAVIGATION
#{{{

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

#DOC> cl :: Clear the screan and list dir content [NAVIGATION]
alias cl='clear && ls -Glh'

#DOC> ch :: Go home and list home content [NAVIGATION]
alias ch='clear && cd && pwd && ls -Glh'

#DOC> tmp :: Go to tmp dir [NAVIGATION]
alias tmp='cd /tmp'

#DOC> home :: Go to home dir [NAVIGATION]
alias home='cd && pwd && ls -FG'

#DOC> documents :: Go to Documents dir and ls [NAVIGATION]
alias documents='cd ~/Documents && pwd && ls -FG'

#DOC> downloads :: Go to Downloads dir and ls [NAVIGATION]
alias downloads='cd ~/Downloads && pwd && ls -FG'

#DOC> projects :: Go to Projects dir and ls [NAVIGATION]
alias projects='cd ~/Projects && pwd && ls -FG'

#DOC> cdl :: Change directory and ll [NAVIGATION]
function cdl {
    cd $1 || return
    ll
}

#DOC> cds :: Change directory and ls [NAVIGATION]
function cds {
    cd $1 || return
    ls
}

#DOC> goto STR... :: Goto a matching directory on the system [NAVIGATION]
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

    local DIR
    local -a DIRS=(${(s.:.)GOTO_PATH})  # Split on :
    local -a FILTERS=(-name "*$1*")
    test -n "$2" && FILTERS+=(-and -name "*$2*")
    test -n "$3" && FILTERS+=(-and -name "*$3*")

    local -a TARGETS
    for DIR in $(find $DIRS -type d -maxdepth 1 -mindepth 1 -and $FILTERS) 
    do
        # An exact match wins
        if (( $# == 1 )) && [[ $1 == ${DIR##*/} ]]; then
            TARGETS=($DIR)
            break
        fi
        TARGETS+=($DIR)
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

#}}}

# ------------------------------------------------------------------------------
# DOTFILES
#{{{

#DOC> dot :: Git alias for dotfiles bare repo [DOTFILES]
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dlg :: Dotfiles lazygit alias [DOTFILES]
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dls :: List all dotfiles [DOTFILES]
function dls {
    pushd -q $HOME
    dot ls-tree -r main | awk '{ print $4}' | xargs ls -l
    popd &>/dev/null
}

#DOC> dst :: Show dotfiles repo status [DOTFILES]
function dst {
    pushd -q $HOME
    dot status --show-stash
    popd -q
}

#DOC> dsync :: Synchronize the dotfiles repo [DOTFILES]
function dsync {
    pushd -q $HOME

    # Commit a dirty repo
    if dot-is-dirty
    then
        dot status --untracked-files=no 
        gum confirm 'Commit changes?' || return 1

        # Update version for modified files
        for FILE in $(dot status -uno --porcelain=v1 | awk '{ print $2 }')
        do
            dot-increase-version $FILE
        done

        dot commit -av ||
        gum confirm 'Continue sync?' ||
        return 1
    fi

    dot pull --rebase &&
    dot push
    popd -q
}

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
    test -n "$(dot status --untracked-files=no --porcelain)"
}


#DOC> edit-dotfile FILE... :: Edit a dotfile and sync dotfile repo [DOTFILES]
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
#}}}

# ------------------------------------------------------------------------------
# UPDATE DOCTOR SETUP ST GOTO
#{{{

#DOC> doctor :: Do some sanity checks of the system [CORE]
function doctor {
    for P in ${(s.:.)PATH}; do
        test -d $P || echo "PATH: $P not found"
    done
}

#DOC> setup-system :: TODO Setup the current system [MISC]
function setup-system {
    err "NOT IMPLEMENTED"
    return 1

    header Homebrew
    if ! exists brew
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install -q $HOMEBREW_APPS
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

#DOC> update :: Update the system [CORE]
function update {
    neofetch

    header 'Rogu'
    rogu -v update

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
    brew update && brew upgrade

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
            cargo install $APP
        done
    else
        echo "\nRUST_APPS is empty."
    fi
}

#}}}

# ------------------------------------------------------------------------------
# NEOVIM
#{{{

#DOC> n :: Start Neovim [NEOVIM]
alias n="nvim"

#DOC> ns :: Start Neovim from a saved session [NEOVIM]
alias ns="nvim -S"

#DOC> no :: Start Neovim with vsplit windows [NEOVIM]
alias no="nvim -O"

#DOC> nd :: Start Neovim in diff mode [NEOVIM]
alias nd="nvim -d"

#DOC> edit-nvim :: Edit the Neovim config setup [DOTFILES]
function edit-nvim {
    pushd -q ~/.config/nvim
    $EDITOR .
    popd -q
}

#}}}

# ------------------------------------------------------------------------------
# PYTHON
#{{{

#DOC> ipy :: IPython alias with flags. [PYTHON]
alias ipy='ipython3 --autocall=1 --pprint'
#DOC> activate-venv :: Activate venv at "venv/bin/activate" [PYTHON]
alias activate-venv='source venv/bin/activate'

#DOC> pyN   :: Alias for `python3.N` [PYTHON]
#DOC> pyNm  :: Alias for `python3.N -m` [PYTHON]
#DOC> pipN  :: Alias for `python3.N -m pip` [PYTHON]
#DOC> venvN :: Alias for `python3.N venv --upgrade-deps venv` [PYTHON]
for N in $(seq 4 20); do
    if exists python3.$N
    then
        alias py${N}="python3.$N"
        alias py${N}m="python3.$N -m"
        alias pip${N}="python3.$N -m pip"
        alias venv${N}="python3.$N -m venv --upgrade-deps venv"
    fi
done

#}}}

# ------------------------------------------------------------------------------
# JVM
#{{{

#DOC> jdump :: Dump class file (javap w/options) [JVM]
alias jdump='javap -c -p -s'

#}}}

# ------------------------------------------------------------------------------
# ROGU
#{{{

#DOC> rogu :: Rogu the alien [ROGU]

#DOC> drogu :: Run Rogu in debug mode [ROGU]
alias drogu='python3 ~/bin/rogu'

#DOC> rogu-help :: Pretty-print rogu's help page with glow [ROGU]
alias rogu-help='rogu help | glow'

#}}}

# ------------------------------------------------------------------------------
# COMPLETION
#{{{

# See:
#   manpage zshcompsys
#    https://thevaluable.dev/zsh-completion-guide-examples/
#   https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org

# Set completers
#   _extensions  : Complete the glob *. with possible file extensions
#   _complete    : The main completer needed for completion.
#   _approximate : Try to correct what you've already typed if no match is found.
zstyle ':completion:*' completer _extensions _complete _approximate


# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Print description headers for completions
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
# Print completion messages and warnings
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches --%f'

# Group matches under their description header
zstyle ':completion:*' group-name ''

#}}}

# ------------------------------------------------------------------------------
# MISC
#{{{

#DOC> path :: List all directories in PATH [MISC]
alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'

#DOC> lines :: Count the lines a file [MISC]
alias lines='wc -l'

#DOC> backup FILE... :: Create a backup of files [MISC]
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

#DOC> makels [FILE] :: List makefile targets [MISC]
function makels {
    local FILE=${1:-Makefile}
    cat $FILE | egrep -o '^\w+:' | tr -d ':' | sort | column
}

#}}}

# ------------------------------------------------------------------------------
# OUTRO

if exists brew
then
    # brew command completion
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

if [[ -d ~/lib ]]; then
    export PERL5LIB="$HOME/lib:$PERL5LIB"
    export PYTHONPATH="$HOME/lib:$PYTHONPATH"
fi

if [[ -f $HOME/.myzshrc ]]; then
    echo "-> .myzshrc"
    source $HOME/.myzshrc
else
    info ".myzshrc not found."
fi

if [[ -d "$HOME/.config/zsh/functions" ]]; then
    fpath=("$HOME/.config/zsh/functions" $fpath)
    autoload -Uz compinit && compinit
fi

if ! exists rogu
then
    err "Rogu is not installed!"
    echo "Install rogu from https://ugor.hirth.dev"
fi

# Warn about missing applications which are essential for my
# zsh setup to work as intended.
for APP in brew git gh starship gum neofetch fortune cowsay glow
do
    exists $APP || warn "Not installed: $APP"
done

if exists starship
then
    # Awesome prompt customization
    eval "$(starship init zsh)"
fi

info "Remember to run \`update\` and \`help\`"

if exists fortune cowsay
then
    fortune | cowsay -n
fi

# Greetings!
local D=$(date +%H)
if (( $D < 6 )); then
    echo "Why are you awake at this hour? 🤔"
elif (( $D < 12 )); then
    echo "Good morning! ☀️"
elif (( $D < 18 )); then
    echo "Good evening! 🐉"
else
    echo "Good night! 🌙"
fi

