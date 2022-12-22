# vim: filetype=zsh:

autoload -U colors && colors

function __info  { echo "\e[${color[faint]};${color[default]}m[·] $*$reset_color" }
function __emph  { echo "$fg_bold[default][*] $*$reset_color" }
function __warn  { echo "$fg_bold[yellow][!] $*$reset_color" }
function __err   { echo "$fg_bold[red][!!] $*$reset_color" }
function __good  { echo "$fg_bold[green][✓] $*$reset_color" }
function __bad   { echo "$fg_bold[red][✗] $*$reset_color" }
function __bold  { echo "$fg_bold[default]$*$reset_color" }

__emph "Zshrc v1.5.0"

export EDITOR='nvim'
export PAGER='less'

export GOTO_PATH=(
	$HOME/Documents
	$HOME/Downloads
)


################################################################################
# PATH
#
#{{{

__info "PATHs"

export PATH="$HOME/bin:$PATH"

# Homebrew
if [[ -d /opt/homebrew ]]; then
	export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
elif [[ -d $HOME/homebrew ]]; then
	export PATH="$PATH:$HOME/homebrew/bin:$HOME/homebrew/sbin"
else
	__bad "Homebrew root folder not found."
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
# Oh my zsh
#
#{{{

__info "Oh-my-zsh"

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
	__bad "Oh my zsh is not installed!"
fi
#}}}


################################################################################
# Aliases
#
#{{{

__info "Aliases"

alias l="ls -F"
alias ll="ls -lh"
alias l1="ls -1hF"
alias lsd="ls -hd *(/)"
alias lld="ls -lhd *(/)"
alias less="less -r"

alias n="nvim"
alias ns="nvim -S"

alias lg='lazygit'
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'

alias pyvenv='python3 -m venv --upgrade-deps venv'
alias ipy='ipython3 --autocall=1 --pprint'
alias activate-venv='source venv/bin/activate'

for N in $(seq 4 20); do
	if which python3.$N &>/dev/null
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

alias tmp='cd /tmp'
#}}}


################################################################################
# Functions
#
#{{{

__info "Functions"

function cdl {
	cd $1 || return
	ll
}


function cdls {
	cd $1 || return
	ls
}

function home {
	echo $HOME
	cd $HOME
	ll
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
	type selector &>/dev/null || {
		__bad "'selector' not installed."
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

function todo {
	if [[ -n "$(git_repo_name)" ]]; then
		git grep TODO
	else
		grep -r TODO .
	fi
}

function update {
	__bold "Rogu update"
	echo "-----------"
	rogu sync

	__bold "\nHomebrew update"
	echo "---------------"
	brew update && brew upgrade
}
#}}}


################################################################################
# Completion
#
# See:
#   manpage zshcompsys
#	https://thevaluable.dev/zsh-completion-guide-examples/
#   https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
#
#{{{

__info "Completion"

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
# Misc
#
#{{{

__info "Misc"
  
#
# EDITOR validation w/fallback
#
if ! type $EDITOR &>/dev/null
then
	__warn "Editor $EDITOR not found!"
	export EDITOR='vi'
fi


#
# Check essential and non-essential applications, respectively
#
for APP in rogu brew git gh starship thefuck; do
	type $APP &>/dev/null || __bad "Not installed: $APP"
done
for APP in neofetch fortune cowsay rg pandoc tag; do
	type $APP &>/dev/null || __warn "Not installed: $APP"
done


#
# Remaining homebrew setup
#
if type brew &>/dev/null
then
	# brew command completion
	FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
	autoload -Uz compinit
	compinit
fi


#
# Library paths
#
if [[ -d ~/lib ]]; then
	export PERL5LIB="$HOME/lib:$PERL5LIB"
	export PYTHONPATH="$HOME/lib:$PYTHONPATH"
else
	__warn "Custom libraries directory not found (~/lib)"
fi


if [[ -f ~/.iterm2_shell_integration.zsh ]]; then
	source ~/.iterm2_shell_integration.zsh
else
	__info "iTerm2 integration script not found (~/.iterm2_shell_integration.zsh)"
fi


if [[ -f $HOME/.myzshrc ]]; then
	source $HOME/.myzshrc
else
	__info "Local RC file (~/.myzshrc) not found."
fi


eval "$(thefuck --alias)"
eval "$(starship init zsh)"
eval "$(kladd --completion)"

echo
neofetch
fortune | cowsay -n
echo
__info "Remember to update"

local D=$(date +%H)
if (( $D < 6 )); then
	__warn "Why are you awake at this hour? 🤔"
elif (( $D < 12 )); then
	__good "Good morning! ☀️"
elif (( $D < 18 )); then
	__good "Good evening! 🐉"
else
	__good "Good night! 🌙"
fi
#}}}
