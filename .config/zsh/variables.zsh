# Path glob'ing will not cause errors, but return no result instead.
setopt NULL_GLOB

export EDITOR='nvim'
export PAGER='less'

#DOC> HELP_FILES :: Files for `help` to search :: VARIABLES
export HELP_FILES=( $HOME/.zshrc $HOME/.config/zsh/**/*.zsh )

#DOC> TODO_PATH :: Paths for the todo script (: separated) :: VARIABLES
export TODO_PATH="$HOME/Projects:$HOME/Documents"

#DOC> GIT_REPOS :: Zsh array of repo directories for `update` :: VARIABLES
export GIT_REPOS=()

#DOC> GOTO_DIRS :: Possible targets directories for `goto` :: VARIABLES
export GOTO_DIRS=( $HOME/Projects/*(/) )

#DOC> GO_APPS :: Zsh array of go applications for `update` :: VARIABLES
export GO_APPS=(
    github.com/mhmorgan/todo@latest
    github.com/mhmorgan/watch@latest
)

#DOC> RUST_APPS :: Zsh array of rust applications for `update` :: VARIABLES
export RUST_APPS=()

if [[ -d ~/lib ]]; then
    export PERL5LIB="$HOME/lib:$PERL5LIB"
    export PYTHONPATH="$HOME/lib:$PYTHONPATH"
fi

export HOMEBREW_CASKS=(
    xquarts # X.Org windows system for mac
)

