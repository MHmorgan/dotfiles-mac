
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

#DOC> GIT_REPOS :: Zsh array of repo directories for `update` [VARIABLES]
export GIT_REPOS=()

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

if [[ -d ~/lib ]]; then
    export PERL5LIB="$HOME/lib:$PERL5LIB"
    export PYTHONPATH="$HOME/lib:$PYTHONPATH"
fi

