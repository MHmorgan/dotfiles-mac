# vim: filetype=zsh:

autoload -U colors && colors

function __info { echo "$fg_bold[default][*] $*$reset_color" }
function __good { echo "$fg_bold[green][✓] $*$reset_color" }
function __warn { echo "$fg_bold[yellow][!] $*$reset_color" }
function __bad  { echo "$fg_bold[red][✗] $*$reset_color" }


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

export PATH="$HOME/bin:$PATH"

# Homebrew
if [[ -d /opt/homebrew ]]; then
	export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
elif [[ -d $HOME/homebrew ]]; then
	export PATH="$PATH:$HOME/homebrew/bin:$HOME/homebrew/sbin"
else
	__bad "Homebrew root folder not found."
fi

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

alias ll="ls -l"
alias l1="ls -1"
alias lsd="ls -d *(/)"
alias lld="ls -lhd *(/)"
alias less="less -r"

alias n="nvim"
alias ns="nvim -S"

alias lg='lazygit'
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'

alias pyvenv='python3 -m venv --upgrade-deps venv'
alias ipython='ipython3 --autocall=1 --pprint'

alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'
alias aliases='alias | sort | less'

alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
#}}}


################################################################################
# Functions
#
#{{{

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


function goto {
	type selector &>/dev/null || {
		__bad "'selector' not installed."
		return 1
	}
	local SEL=$(selector ${=GOTO_PATH} -af "$*")
	[[ -n "$SEL" ]] || return
	local DIR=$SEL
	echo $DIR
	# -P use the physical directory structure instead of following symbolic links
	cd -P $DIR
	ll
}
#}}}


################################################################################
# Misc
#{{{

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
for APP in brew git gh starship thefuck; do
	type $APP &>/dev/null || __bad "Not installed: $APP"
done
for APP in neofetch fortune cowsay rg pandoc tag; do
	type $APP &>/dev/null || __warn "Not installed: $APP"
done


eval "$(thefuck --alias)"
eval "$(starship init zsh)"

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


if [[ -f $HOME/.myzshrc ]]; then
	source $HOME/.myzshrc
else
	__info "Local RC file (~/.myzshrc) not found."
fi


echo
neofetch
fortune | cowsay -n
#}}}
