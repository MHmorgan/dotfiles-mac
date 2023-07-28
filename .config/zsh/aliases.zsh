# All my Zsh aliases (except ls)

# NAVIGATION {{{

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

#DOC> cl :: Clear the screan and list dir content :: NAVIGATION
alias cl='clear && ls -Glh'

#DOC> ch :: Go home and list home content :: NAVIGATION
alias ch='clear && cd && pwd && ls -Glh'

#DOC> home/etc. :: Move to home/documents/downloads/projects/tmp :: NAVIGATION
alias home='cd && pwd && ls -FG'
alias documents='cd ~/Documents && pwd && ls -FG'
alias downloads='cd ~/Downloads && pwd && ls -FG'
alias projects='cd ~/Projects && pwd && ls -FG'
alias tmp='cd /tmp'

#DOC> cdl/cds :: Change directory and ls/ll :: NAVIGATION
function cdl {
    cd $1 || return
    ll
}
function cds {
    cd $1 || return
    ls
}
#}}}

# GIT {{{

#DOC> lg :: Start lazygit :: GIT
alias lg='lazygit'

#DOC> glog :: Print the last 7 log entries :: GIT
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'

#DOC> glist :: List my non-archived GitHub repos :: GIT
alias glist='gh repo list --no-archived'

#DOC> gclone :: Clone a GitHub repo :: GIT
alias gclone='gh repo clone'

#DOC> gc :: Git commit alias :: GIT
alias gc='git commit --verbose'

#DOC> gca :: Git commit all alias :: GIT
alias gca='git commit --verbose --all'

#DOC> gst :: Git status alias :: GIT
alias gst='git status'
#}}}

# DOTFILES {{{

#DOC> dot :: Git alias for dotfiles bare repo :: DOTFILES
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dlg :: Dotfiles lazygit alias :: DOTFILES
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
#}}}

# NEOVIM {{{

#DOC> n :: Start Neovim :: NEOVIM
alias n="nvim"

#DOC> ns :: Start Neovim from a saved session :: NEOVIM
alias ns="nvim -S"

#DOC> no :: Start Neovim with vsplit windows :: NEOVIM
alias no="nvim -O"

#DOC> nd :: Start Neovim in diff mode :: NEOVIM
alias nd="nvim -d"
#}}}

# PYTHON {{{

#DOC> ipy :: IPython alias with flags. :: DEV
alias ipy='ipython3 --autocall=1 --pprint'
#DOC> py-activate :: Activate venv at "venv/bin/activate" :: DEV
alias py-activate='source venv/bin/activate'
#}}}

# JVM {{{

#DOC> jdump :: Dump class file (javap w/options) :: DEV
alias jdump='javap -c -p -s'
#}}}


# MISC

alias drogu='python3 ~/bin/rogu'

#DOC> help :: Print this help message :: INFO
alias help='cat $HELP_FILES | python3 ~/.config/zsh/misc/help.py | glow'

#DOC> print-?? :: Print some specific information. :: INFO
alias print-path='echo ${PATH//:/\\n} | sort'
alias print-gotos='echo ${(j:\n:)GOTO_DIRS} | sed "s/${HOME//\//\\/}/~/" | sort'
alias print-repos='echo ${(j:\n:)GIT_REPOS} | sed "s/${HOME//\//\\/}/~/" | sort'
alias print-helpfiles='echo ${(j:\n:)HELP_FILES} | sed "s/${HOME//\//\\/}/~/" | sort'

#DOC> lines :: Count the lines a file
alias lines='wc -l'

#DOC> loc :: Count the lines of code by filtering out empty lines from stdin
alias loc='egrep -v "^\s*\$" | wc -l'

