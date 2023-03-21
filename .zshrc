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

function m-header { gum style --border=rounded --border-foreground="#ff6d67" --width=20 --align=center --margin="1 0" "$*" }
function m-log { echo -n "$(tput el)$*\r" }
#}}}

m-emph "Zshrc Mac v89"

export EDITOR='nvim'
export PAGER='less'

export GOTO_PATH=(
	$HOME/Documents
	$HOME/Downloads
)


################################################################################
#
# PATH
#
################################################################################

m-log "PATHs"

export PATH="$HOME/bin:$PATH"

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

# Dart & Flutter
export PATH="$PATH:/usr/lib/dart/bin:$HOME/flutter/bin:$HOME/.pub-cache/bin"

# PostgreSQL
export PATH="$PATH:/usr/lib/postgresql/13/bin"
#}}}


################################################################################
#
# Oh my zsh
#
################################################################################

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
	chucknorris
	docker
	gh
	git
	golang
	pip
	pylint
	python
	ripgrep
	rust
	thefuck
	tmux
	vscode
)

if [[ -d $ZSH ]]; then
	source $ZSH/oh-my-zsh.sh
else
	m-bad "Oh my zsh is not installed!"
fi
#}}}


################################################################################
#
# Aliases
#
################################################################################

m-log "Aliases"

alias l="ls -F"
alias ll="ls -lh"
alias l1="ls -1hF"
alias lsf="ls -hd *(.)"
alias llf="ls -lhd *(.)"
alias lsd="ls -hd *(/)"
alias lld="ls -lhd *(/)"
alias less="less -r"

alias cl='clear && ls -lh'
alias ch='clear && home'
alias tmp='cd /tmp'

alias n="nvim"
alias ns="nvim -S"

alias lg='lazygit'
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'

alias pyvenv='python3 -m venv --upgrade-deps venv'
alias ipy='ipython3 --autocall=1 --pprint'
alias activate-venv='source venv/bin/activate'

for N in $(seq 4 20); do
	if m-exists python3.$N
	then
		alias py${N}="python3.$N"
		alias py${N}m="python3.$N -m"
		alias pip${N}="python3.$N -m pip"
		alias venv${N}="python3.$N -m venv"
	fi
done

alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'
alias aliases='alias | sort | less'

alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias sshserver='ssh m@134.122.59.44'
#}}}


################################################################################
#
# Functions
#
################################################################################

m-log "Functions"

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

function editdotfile {
	m-exists rogu || { m-err "rogu not installed!"; return 1 }

	if [[ -z "$1" ]]; then
		rogu list
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

	rogu sync dotfiles
}

function editreadme {
	m-exists selector || { m-bad "'selector' not installed."; return 1 }

	if [[ -z "$1" ]]; then
		m-bad 'missing repo name'
		return 1
	fi

	local DIR=$(selector -filter "$*" ${=GOTO_PATH})
	[[ -n "$DIR" ]] || return
	pushd -q $DIR

	function () {
		# Must be clean to side effects
		if [[ -n "$(git status --short)" ]]; then
			m-warn "repo is dirty - must be clean"
			m-info $PWD
			git status
			return 1
		fi

		# Find readme file
		local FILE=$(find . -iname 'readme.*' -maxdepth 5)
		if [[ -z $FILE ]]; then
			m-bad "no readme in $DIR"
			return 1
		fi

		m-info "Editing $FILE"
		$EDITOR $FILE || return $?

		# Stop if no changes were made
		[[ -n "$(git status --short)" ]] || return

		m-info "Committing..."
		git commit -m "Update $FILE" $FILE &&
		m-info "Pushing..." &&
		git push
	}

	local res=$?
	popd -q
	return $res
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

function help {
	local W=80

	m-header Applications
	pushd -q ~/bin
	print -l *(x) | column -c$W
	popd -q

	m-header Libraries
	pushd -q ~/lib
	print -l *(.) | column -c$W
	popd -q

	m-header Aliases
	cat ~/.{,my}zshrc | perl -nE 'say $1 if /^alias +([^_][^=]*)/' | sort | column -c$W

	m-header Functions
	cat ~/.{,my}zshrc | perl -nE 'say $1 if /^function +([^_]\S*)/' | sort | column -c$W
}

function home {
	echo $HOME
	cd $HOME
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

function todo {
	local re='(TODO|FIXME|BUG)'
	if [[ -n "$(git_repo_name)" ]]; then
		git grep -E $re
	else
		grep -rE $re .
	fi
}

function update {
	m-ifexists neofetch

	m-header Rogu
	rogu sync

	echo
	m-header Homebrew
	brew update && brew upgrade
}


################################################################################
#
# Completion
#
# See:
#   manpage zshcompsys
#	https://thevaluable.dev/zsh-completion-guide-examples/
#   https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
#
################################################################################

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


################################################################################
#
# Homebrew
#
################################################################################

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


################################################################################
#
# Applications
#
################################################################################

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
#
# Misc
#
################################################################################

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
#
# Outro
#
################################################################################


m-info "Remember to run \`update\`"

UPDATED=$(date '+%Y%m%d')
if ! [[ -f ~/.cache/rogu-updated && "$UPDATED" == "$(cat ~/.cache/rogu-updated)" ]]
then
	mkdir -p ~/.cache
	echo $UPDATED > ~/.cache/rogu-updated
	m-ifexists rogu doctor
fi


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

