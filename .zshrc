# vim: filetype=zsh:tabstop=4:shiftwidth=4:expandtab:

echo "Zshrc Mac v136"

# ------------------------------------------------------------------------------
# CORE

autoload -U colors && colors
function info   { echo "\e[${color[faint]};${color[default]}m$*$reset_color" }
function warn   { echo "$fg_bold[yellow]WARN: $*$reset_color" }
function err    { echo "$fg_bold[red]ERROR: $*$reset_color" }
function bold   { echo "$fg_bold[default]$*$reset_color" }
function exists { which $* &>/dev/null }
function header { gum style --border=rounded --width=20 --align=center --margin="1 0" "$*" }

export EDITOR='nvim'
export PAGER='less'

export HELP_PATH="$HOME/help-pages"
export HELP_FILES="$HOME/.zshrc:$HOME/.vimrc:$HOME/.myzshrc"

export GOTO_PATH="$HOME/Documents:$HOME/Downloads:$HOME/Projects"

alias ls="ls -FG"
alias la="ls -AFG"
alias ll="ls -Glh"
alias lla="ls -AGlh"
alias l1="ls -1FGh"

alias help='help.py | glow'

# ------------------------------------------------------------------------------
# PATH
#{{{

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

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

#}}}

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
    if git status --porcelain=v1 | egrep '^.[^?!]'
    then
        gum confirm 'Commit changes?' &&
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

#DOT> status :: Show git and gh status for repos [GIT]
# TODO Visit all repos from REPO_PATH
function status {

    #if git status --porcelain=v1 | egrep '^.[^?!]'
    if [[ -n $(git_repo_name) ]]; then
        echo
        header "Git"
        git status --show-stash
    fi

    header "GitHub"
    gh status
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

#}}}

# ------------------------------------------------------------------------------
# NAVIGATION
#{{{

alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias .....='cd .....'

#DOC> cl :: Clear the screan and list dir content [NAVIGATION]
alias cl='clear && ls -lh'

#DOC> ch :: Go home and list home content [NAVIGATION]
alias ch='clear && cd && pwd && ls -lh'

#DOC> tmp :: Go to tmp dir [NAVIGATION]
alias tmp='cd /tmp'

#DOC> home :: Go to home dir [NAVIGATION]
alias home='cd && pwd && ls -G'

#DOC> documents :: Go to Documents dir and ls [NAVIGATION]
alias documents='cd ~/Documents && pwd && ls -G'

#DOC> downloads :: Go to Downloads dir and ls [NAVIGATION]
alias downloads='cd ~/Downloads && pwd && ls -G'

#DOC> projects :: Go to Projects dir and ls [NAVIGATION]
alias projects='cd ~/Projects && pwd && ls -G'

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
    local -a TARGETS FILTERS
    local DIR TMP

    if ! exists gum
    then 
        err "'gum' not installed."
        return 1
    fi
    
    if (( $# == 0 ))
    then
        err 'Need some input...'
        return 1
    fi

    FILTERS+=(-name "*$1*")
    test -n "$2" && FILTERS+=(-and -name "*$2*")
    test -n "$3" && FILTERS+=(-and -name "*$3*")

    for DIR in ${(s.:.)GOTO_PATH}  # Split on :
    do
        for TMP in $(find $DIR/* -maxdepth 0 -and $FILTERS)
        do
            TARGETS+=($TMP)
        done
    done

    if (( ${#TARGETS} <= 1 ))
    then
        DIR=$TARGETS
    else
        DIR=$(gum choose --header='Where to goto?' $TARGETS)
    fi
    if ! [[ -n "$DIR" ]]
    then
        err "Nowhere to go :("
        return 1
    fi

    echo $DIR
    # -P use the physical directory structure instead of following symbolic links
    cd -P $DIR
    ll
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
    dot status
    popd -q
}

#DOC> dsync :: Synchronize the dotfiles repo [DOTFILES]
function dsync {
    pushd -q $HOME
    if dot status --porcelain=v1 | egrep '^.[^?!]'
    then
        gum confirm 'Commit changes?' &&
        dot commit -av ||
        gum confirm 'Continue sync?' ||
        return 1
    fi
    dot pull --rebase &&
    dot push
    popd -q
}

#DOC> edit-dotfile :: Edit a dotfile and sync dotfile repo [DOTFILES]
function edit-dotfile {
    if [[ -z "$1" ]]; then
        err "Missing dotfile."
        return
    fi

    local fpath=~/$1
    local ftmp=/tmp/dotfiles/$1
    mkdir -p /tmp/dotfiles

    local edit=$EDITOR
    [[ -n "$edit" ]] || edit=vi
    $edit $fpath

    # Return if there were no changes
    if [[ -z "$(dot status --short)" ]]; then
        return
    fi

    # Increase version number for .zshrc
    if [[ $fpath =~ ".zshrc$" ]]; then
        local old=$(cat $fpath | perl -nE 'say $1 if /"Zshrc ?\w* (v\d+)"$/')
        cat $fpath | perl -pE '
            next unless /"Zshrc ?\w* v(\d+)"$/;
            my $num = $1 + 1;
            $_ =~ s/$1/$num/;
        ' > $ftmp &&
        mv $ftmp $fpath
        local new=$(cat $fpath | perl -nE 'say $1 if /"Zshrc ?\w* (v\d+)"$/')
        echo ".zshrc $old -> $new"
    fi

    dot commit -am "Update $1" &&
    dot pull --rebase &&
    dot push
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
# HOMEBREW
#{{{

export HOMEBREW_APPS=(
    cheat
    cowsay
    docker
    elm
    figlet
    fortune
    gcc
    gh
    glow
    go
    graphviz
    gum
    ipython
    jupyterlab
    lazygit
    mysql
    neofetch
    neovim
    pandoc
    pipgrip
    plantuml
    python-tk
    python
    ripgrep
    rust
    sl
    starship
    tag
    thefuck
    tldr
    tmux
)

# TODO Move homebrew install stuff to a bin/ script?
function brewinstall {
    if ! exists brew
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install -q $HOMEBREW_APPS
}


if exists brew
then
    # brew command completion
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

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

#DOC> todo :: List todo entries [MISC]
# TODO Add a status function which looks for TODOs?
# TODO Outsource `todo` to a xonsh script?
function todo {
    local re='(TODO|FIXME|BUG)'
    if [[ -n "$(git_repo_name)" ]]; then
        git grep -E $re
    else
        # TODO Use TODO_PATH and `find` with `xargs`
        # TODO Also use REPO_PATH with `git grep`
        grep -rE $re .
    fi
}

#DOC> update :: Update the system [MISC]
# TODO Outsource `update` to a xonsh script?
function update {
    neofetch

    header Rogu
    rogu -v update

    header Dotfiles
    if dot status --porcelain=v1 | egrep '^.[^?!]'
    then
        if gum confirm 'Commit changes and sync?'
        then
            dot commit -av &&
            dot pull --rebase &&
            dot push
        fi
    else
        dot pull --rebase &&
        dot push
    fi

    # TODO Update git repos? For repos in REPO_PATH do a pull if they're clean?

    header Homebrew
    brew update && brew upgrade
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

if [[ -d ~/lib ]]; then
    export PERL5LIB="$HOME/lib:$PERL5LIB"
    export PYTHONPATH="$HOME/lib:$PYTHONPATH"
fi

if [[ -f $HOME/.myzshrc ]]; then
    source $HOME/.myzshrc
else
    info "Local RC file (~/.myzshrc) not found."
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

info "Remember to run \`update\`"

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

