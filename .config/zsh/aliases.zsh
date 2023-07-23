# All my Zsh aliases (except ls)

# NAVIGATION {{{

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
#}}}

# GIT {{{

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
#}}}

# DOTFILES {{{

#DOC> dot :: Git alias for dotfiles bare repo [DOTFILES]
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dlg :: Dotfiles lazygit alias [DOTFILES]
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
#}}}

# NEOVIM {{{

#DOC> n :: Start Neovim [NEOVIM]
alias n="nvim"

#DOC> ns :: Start Neovim from a saved session [NEOVIM]
alias ns="nvim -S"

#DOC> no :: Start Neovim with vsplit windows [NEOVIM]
alias no="nvim -O"

#DOC> nd :: Start Neovim in diff mode [NEOVIM]
alias nd="nvim -d"
#}}}

# PYTHON {{{

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

# JVM {{{

#DOC> jdump :: Dump class file (javap w/options) [JVM]
alias jdump='javap -c -p -s'
#}}}

# ROGU {{{

#DOC> rogu :: Rogu the alien [ROGU]
#DOC> drogu :: Run Rogu in debug mode [ROGU]
alias drogu='python3 ~/bin/rogu'

#DOC> rogu-help :: Pretty-print rogu's help page with glow [ROGU]
alias rogu-help='rogu help | glow'
#}}}

# MISC

#DOC> path :: List all directories in PATH [MISC]
alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'

#DOC> lines :: Count the lines a file [MISC]
alias lines='wc -l'