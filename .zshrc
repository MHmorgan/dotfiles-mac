# vim: filetype=zsh:

#{{{ Pretty-printing
autoload -U colors && colors

function m-info  { echo "\e[${color[faint]};${color[default]}m[·] $*$reset_color" }
function m-emph  { echo "$fg_bold[default][*] $*$reset_color" }
function m-warn  { echo "$fg_bold[yellow][!] $*$reset_color" }
function m-err   { echo "$fg_bold[red][!!] $*$reset_color" }
function m-good  { echo "$fg_bold[green][✓] $*$reset_color" }
function m-bad   { echo "$fg_bold[red][✗] $*$reset_color" }
function m-bold  { echo "$fg_bold[default]$*$reset_color" }

function m-exists   { which $* &>/dev/null }
function m-ifexists { which $1 &>/dev/null && $* }

function m-header { gum style --border=rounded --width=20 --align=center --margin="1 0" "$*" }
function m-log { echo -n "$(tput el)$*\r" }
#}}}

m-emph "Zshrc Mac v121"

export EDITOR='nvim'
export PAGER='less'

export HELP_DIR=$HOME/help-pages
export HELP_FILES="$HOME/.zshrc:$HOME/.vimrc:$HOME/.myzshrc"

# The paths used by the goto function
export GOTO_PATH=(
	$HOME/Documents
	$HOME/Downloads
)


################################################################################
# PATH
#{{{

m-log "PATHs"

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Homebrew
if [[ -d /opt/homebrew ]]; then
	export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
elif [[ -d $HOME/homebrew ]]; then
	export PATH="$PATH:$HOME/homebrew/bin:$HOME/homebrew/sbin"
else
	m-bad "Homebrew root folder not found."
fi

# Go
export PATH="$PATH:$HOME/go/bin"

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

#}}}

################################################################################
# Oh my zsh
#{{{

m-log "Oh-my-zsh"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	brew
	docker
	gh
	golang
	pip
	poetry
	python
	rust
	thefuck
	tmux
)

if [[ -d $ZSH ]]; then
	source $ZSH/oh-my-zsh.sh
else
	m-bad "Oh my zsh is not installed!"
fi

#}}}

################################################################################
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

#}}}

################################################################################
# Aliases
#{{{

m-log "Aliases"

#DOC> cl :: Clear the screan and list dir content
alias cl='clear && ls -lh'
#DOC> ch :: Go home and list home content
alias ch='clear && cd && pwd && ls -lh'
#DOC> tmp :: Go to tmp dir
alias tmp='cd /tmp'
#DOC> home :: Go to home dir
alias home='cd && pwd && ls -G'
#DOC> documents :: Go to Documents dir and ls
alias documents='cd ~/Documents && pwd && ls -G'
#DOC> downloads :: Go to Downloads dir and ls
alias downloads='cd ~/Downloads && pwd && ls -G'

alias l="ls -F"
alias ll="ls -lh"
alias l1="ls -1hF"
alias lsf="ls -hd *(.)"
alias llf="ls -lhd *(.)"
alias lsd="ls -hd *(/)"
alias lld="ls -lhd *(/)"

alias n="nvim"
alias ns="nvim -S"

alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'
alias aliases='alias | sort | less'

alias sshserver='ssh m@134.122.59.44'

#}}}

################################################################################
# DOTFILES
#{{{

#DOC> dot :: Git alias for dotfiles bare repo [DOTFILES]
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dlg :: Dotfiles lazygit alias [DOTFILES]
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

#DOC> dls :: List all dotfiles [DOTFILES]
function dls {
	pushd $HOME &>/dev/null
	dot ls-tree -r main | awk '{ print $4}' | xargs ls -l
	popd &>/dev/null
}

#DOC> edit-dotfile :: Edit a dotfile and sync dotfile repo [DOTFILES]
function edit-dotfile {
	if [[ -z "$1" ]]; then
		m-err "Missing dotfile."
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

################################################################################
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
	if m-exists python3.$N
	then
		alias py${N}="python3.$N"
		alias py${N}m="python3.$N -m"
		alias pip${N}="python3.$N -m pip"
		alias venv${N}="python3.$N -m venv --upgrade-deps venv"
	fi
done

#}}}

################################################################################
# ROGU
#{{{

#DOC> rogu :: Rogu the alien [ROGU]

#DOC> drogu :: Run Rogu in debug mode [ROGU]
alias drogu='python3 ~/bin/rogu'

#DOC> rogu-help :: Pretty-print rogu's help page with glow [ROGU]
alias rogu-help='rogu help | glow'

#}}}

################################################################################
# Functions

m-log "Functions"

#DOC> all_gum_spinners :: Showcase all gum spinners.
function all_gum_spinners {
	for X in line dot minidot jump pulse points globe moon monkey meter hamburger; do
		gum spin --spinner=$X --title=$X sleep 5
	done
}

function backup {
	local src=$1

	if ! [[ -f "$src" ]]
	then
		echo "source file not found: $src"
		return 1
	fi

	cp -vpr $src $src~
}

function cdl {
	cd $1 || return
	ll
}


function cds {
	cd $1 || return
	ls
}

function gitaliases {
	local file=$HOME/.oh-my-zsh/plugins/git/README.md
	local command='
		$2 ~ /^ *g/ {
			gsub(/(^ *| *$)/, "", $2)
			gsub(/(^ *| *$)/, "", $3)
			print $2 "\t" $3
		}
	'
	# Look through all aliases or grep for a some specific aliases
	if (( $# < 1 ))
	then
		awk -F '|' $command $file | less
	else
		awk -F '|' $command $file | grep $@
	fi
}


# Defined it golang oh-my-zsh plugin
unalias goto

# TODO Use `gum` for this instead?
function goto {
	m-exists selector || {
		m-bad "'selector' not installed."
		return 1
	}
	local SEL=$(selector -filter "$*" ${=GOTO_PATH})
	[[ -n "$SEL" ]] || return
	local DIR=$SEL
	echo $DIR
	# -P use the physical directory structure instead of following symbolic links
	cd -P $DIR
	ll
}

#DOC> help :: Combining `help.py` script and `glow`
function help {
	if ! m-exists help.py; then
		m-err "Script 'help.py' not found."
		return 1
	fi
	if ! m-exists glow; then
		m-err "Command 'glow' not found."
		return 1
	fi
	help.py $@ | glow
}

#DOC> helpp :: Combining `help.py` script and `glow` with pager
function helpp {
	if ! m-exists help.py; then
		m-err "Script 'help.py' not found."
		return 1
	fi
	if ! m-exists glow; then
		m-err "Command 'glow' not found."
		return 1
	fi
	help.py $@ | glow --pager
}

function root {
	local DIR=$PWD
	while [[ -n "$DIR" ]]; do
		test -e $DIR/.git && break
		DIR=${DIR%/*}
	done

	if [[ -z "$DIR" ]]; then
		m-err "Not in a git repo"
		return 1
	fi

	echo $DIR
	cd $DIR
	ll
}

function s {
	local USER=m
	local HOST=134.122.59.44

	case $1 in
		*)
			ssh $USER@$HOST
	esac
}

# TODO Add a status function which looks for TODOs?
function todo {
	local re='(TODO|FIXME|BUG)'
	if [[ -n "$(git_repo_name)" ]]; then
		git grep -E $re
	else
		# TODO Use TODO_PATH and `find` with `xargs`
		grep -rE $re .
	fi
}

# TODO Update git repos as well (use gsync)
# TODO Update dotfiles
# Use a REPO_PATHS for where to look?
function update {
	m-ifexists neofetch

	m-header Rogu
	rogu -v update

	echo
	m-header Homebrew
	brew update && brew upgrade
}


################################################################################
# Completion
#{{{

# See:
#   manpage zshcompsys
#	https://thevaluable.dev/zsh-completion-guide-examples/
#   https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org

m-log "Completion"

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

################################################################################
# Homebrew
#{{{

m-log "Homebrew"

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

function brewinstall {
	if ! m-exists brew
	then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	brew install -q $HOMEBREW_APPS
}


if m-exists brew
then
	# brew command completion
	FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
	autoload -Uz compinit
	compinit
fi

#}}}

################################################################################
# Applications

m-log "Applications"

# ESSENTIAL

for APP in rogu brew git gh starship thefuck gum; do
	m-exists $APP || m-bad "Essential command not installed: $APP"
done

# NON-ESSENTIAL

for APP in neofetch fortune cowsay rg pandoc tag glow; do
	m-exists $APP || m-warn "Not installed: $APP"
done


################################################################################
# Misc

m-log "Misc"

#
# EDITOR validation w/fallback
#
if ! type $EDITOR &>/dev/null
then
	m-warn "Editor $EDITOR not found!"
	export EDITOR='vi'
fi


#
# Library paths
#
if [[ -d ~/lib ]]; then
	export PERL5LIB="$HOME/lib:$PERL5LIB"
	export PYTHONPATH="$HOME/lib:$PYTHONPATH"
fi


if [[ -f ~/.iterm2_shell_integration.zsh ]]; then
	m-log "iTerm shell integration"
	source ~/.iterm2_shell_integration.zsh
else
	m-info "iTerm2 integration script not found (~/.iterm2_shell_integration.zsh)"
fi


if [[ -f $HOME/.myzshrc ]]; then
	source $HOME/.myzshrc
else
	m-info "Local RC file (~/.myzshrc) not found."
fi


m-log "thefuck alias"
eval "$(thefuck --alias)"

m-log "starship completion"
eval "$(starship init zsh)"


################################################################################
# Outro

m-info "Remember to run \`update\`"

local D=$(date +%H)
if (( $D < 6 )); then
	m-warn "Why are you awake at this hour? 🤔"
elif (( $D < 12 )); then
	m-good "Good morning! ☀️"
elif (( $D < 18 )); then
	m-good "Good evening! 🐉"
else
	m-good "Good night! 🌙"
fi

if m-exists fortune cowsay
then
	fortune | cowsay -n
fi


