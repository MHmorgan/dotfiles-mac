# vim: filetype=zsh:tabstop=4:shiftwidth=4:expandtab:
#
# Features 
# =========
#
# - [x] Goto often used directories
# - [ ] Install/update GitHub gist files
# - [x] Easy access to quick-help for terminal functionality
# - [ ] Semi-automatic updating applications:
#    - [x] Go apps
#    - [x] Rust apps
#    - [x] Homebrew apps
#    - [ ] Gist binaries
# - [x] Semi-automatic updating git repos
# - [x] Semi-automatic updating dotfiles
# - [x] Super-easy to change dotfiles

# TODO Remove Rogu - replace with gist and boilerplates
# TODO Use .config/zsh/boilerplates for storing script boilerplates

echo "Zshrc Mac :: v173 ::"

# PRINTING FUNCTIONS {{{

autoload -U colors && colors

function info   { echo "\e[${color[faint]};${color[default]}m$*$reset_color" }
function warn   { echo "WARN: $*" }
function err    { echo "ERROR: $*" }
function bold   { echo "$fg_bold[default]$*$reset_color" }

function exists { which $* &>/dev/null }

function header {
    if exists gum; then
        gum style --border=rounded --width=20 --align=center --margin="1 0" "$*"
    else
        echo; bold $*; echo
    fi
}
#}}}

info "-> .zshrc"

# LS ALIASES {{{

alias ls="ls -FG"
alias la="ls -AFG"
alias ll="ls -Glh"
alias lla="ls -AGlh"
alias l1="ls -1FGh"
#}}}

# PATH {{{

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
#}}}

# SYSTEM CHECKS {{{

# Check that some of the most fundamental applications,
# commonly used in scripts and functions, are installed.
exists brew     || warn "'brew' (homebrew) not installed"
exists cargo    || warn "'cargo' (rust) not installed"
exists gh       || warn "'gh' not installed"
exists git      || warn "'git' not installed"
exists glow     || warn "'glow' not installed"
exists go       || warn "'go' not installed"
exists gum      || warn "'gum' not installed"
exists nvim     || warn "'nvim' not installed"
exists perl     || warn "'perl' not installed"
exists python3  || warn "'python3' not installed"
exists starship || warn "'starship' not installed"

# Check if the dotfiles directory structure looks as expected.
if ! [[ -d ~/.config/zsh ]]; then
    warn "~/.config/zsh not found! Please setup dotfiles."
else
    [[ -d ~/.config/zsh/core ]] || warn "~/.config/zsh/core not found! Please setup dotfiles."
    [[ -d ~/.config/zsh/misc ]] || warn "~/.config/zsh/misc not found! Please setup dotfiles."
fi
#}}}

# SOURCE FILES {{{

# Files are sourced from .config/zsh (essential files),
# .config/zsh/core (core files) and .config/zsh/misc (misc files).
#
# The essential files are the least flexible: their ordering are
# pre-defined; they may have inter-dependencies; new essential files
# cannot be dynamically added; they can only depend on .zshrc
#
# The core files are executed in "random" order, they can depend on
# essential files and .zshrc,and cannot have inter-dependencies.
#
# The misc files are executed in "random" order, cannot have
# inter-dependencies, and may depend on .zshrc, essential and core files.

# Don't give an error message if no glob pattern match,
# just continue executing zshrc setup.
setopt NULL_GLOB

for FILE in \
    ~/.config/zsh/variables.zsh \
    ~/.config/zsh/aliases.zsh \
    ~/.config/zsh/completion.zsh
do
    if [[ -f $FILE ]]; then
        source $FILE
    else
        warn "Essential file not found: $FILE"
    fi
done
for FILE in ~/.config/zsh/core/*.zsh; do
    info "-> core/${FILE##*/}"
    source $FILE
done
for FILE in ~/.config/zsh/misc/*.zsh; do
    info "-> misc/${FILE##*/}"
    source $FILE
done
for FILE in ~/.config/zsh/local/*.zsh; do
    info "-> local/${FILE##*/}"
    source $FILE
done
#}}}

# OUTRO {{{

if exists brew
then
    # brew command completion
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit && compinit
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
#}}}

