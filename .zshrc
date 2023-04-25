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

m-emph "Zshrc Mac v117"

export EDITOR='nvim'
export PAGER='less'

export HELP_DIR=$HOME/help-pages
export HELP_FILES="$HOME/.zshrc:$HOME/.vimrc"

# The paths used by the goto function
export GOTO_PATH=(
	$HOME/Documents
	$HOME/Downloads
)


################################################################################
# PATH

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


################################################################################
# Oh my zsh

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


################################################################################
# Aliases

m-log "Aliases"

alias l="ls -F"
alias ll="ls -lh"
alias l1="ls -1hF"
alias lsf="ls -hd *(.)"
alias llf="ls -lhd *(.)"
alias lsd="ls -hd *(/)"
alias lld="ls -lhd *(/)"

alias cl='clear && ls -lh'
alias ch='clear && cd && pwd && ls -lh'
alias tmp='cd /tmp'
alias home='cd && pwd && ls -G'
alias documents='cd ~/Documents && pwd && ls -G'
alias downloads='cd ~/Downloads && pwd && ls -G'

alias n="nvim"
alias ns="nvim -S"

#DOC> lg :: Start lazygit [GIT]
alias lg='lazygit'
#DOC> glog :: Print the last 7 log entries [GIT]
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" -7'
#DOC> glist :: List my non-archived GitHub repos [GIT]
alias glist='gh repo list --no-archived'
#DOC> gclone :: Clone a GitHub repo [GIT]
alias gclone='gh repo clone'

alias path='echo $PATH | sed "s/:/\\n/g" | sort | less'
alias aliases='alias | sort | less'

alias sshserver='ssh m@134.122.59.44'

# DOTFILES

#DOC> dot :: Git alias for dotfiles bare repo [DOTFILES]
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
#DOC> dlg :: Dotfiles lazygit alias [DOTFILES]
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# PYTHON

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

# ROGU

#DOC> drogu :: Run Rogu in debug mode. [ROGU]
alias drogu='python3 ~/bin/rogu'
#DOC> rogu-help :: Pretty-print rogu's help page with glow [ROGU]
alias rogu-help='rogu help | glow'


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


################################################################################
# Homebrew

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




################################################################################
# Cheatsheets

CHEATSHEET_MAC=$(cat<<EOF
afplay          - Plays an audio file.
airport         - Provides information about Wi-Fi networks and manages the Wi-Fi interface.
brctl           - Manages iCloud documents and data.
caffeinate      - Prevents the system from sleeping, displaying the screen saver, or going to sleep.
csrutil         - Manages System Integrity Protection (SIP) settings.
defaults        - Reads, writes, and deletes preferences in macOS.
diskutil        - Manages disks and volumes.
ditto           - Copy folder content to another folder.
hdiutil         - Creates, converts, and manipulates disk images.
ioreg           - Displays the I/O Kit registry, which provides information about devices and drivers in the system.
kextload        - Loads a kernel extension.
kextstat        - Shows the status of loaded kernel extensions.
kextunload      - Unloads a loaded kernel extension.
log             - Interacts with the unified logging system introduced in macOS Sierra and later.
mdfind          - Searches for files using Spotlight metadata.
mdls            - Lists metadata attributes for a file.
networksetup    - Configures network settings.
nvram           - Provides an interface to read and write NVRAM variables, which store system settings like boot arguments and startup disk selection.
open            - Opens a file or directory with the default app, or opens a specified app.
osascript       - Executes AppleScript and other OSA (Open Scripting Architecture) language scripts.
pbcopy          - Copies text from stdin to the clipboard.
pbpaste         - Pastes text from the clipboard to stdout.
pkgutil         - Manages macOS installer packages, such as expanding or querying package information.
plutil          - Converts property list files between formats, such as XML and binary, and can also validate and manipulate the contents.
pmset           - Manages power management settings, such as sleep and wake times, display sleep times, and more.
profiles        - Manages configuration profiles on macOS devices.
say             - Converts text to speech and speaks it aloud.
screencapture   - Takes a screenshot of the screen or a specified area.
scutil          - Provides a command-line interface to the System Configuration framework, allowing you to manage system network configuration.
softwareupdate  - Manages software updates from the command line.
sw_vers         - Shows macOS version information.
system_profiler - Provides detailed information about the system's hardware and software configuration.
tag             - Manipulate and query tags on macOS files (homebrew)
textutil        - Converts text files between different formats, such as HTML, RTF, and plain text.
tmutil          - Manages Time Machine backups.
EOF
)

CHEATSHEET_UNIX=$(cat<<EOF
cheat           - Create and view interactive cheat sheets for *nix commands (homebrew)
cmatrix         - Console Matrix (homebrew)
cowsay          - Configurable talking characters in ASCII art (homebrew)
figlet          - Banner-like program prints strings as ASCII art (homebrew)
fortune         - Infamous electronic fortune-cookie generator (homebrew)
gh              - GitHub command-line tool (homebrew)
glow            - Render markdown in the CLI (homebrew)
gum             - Tool for glamorous shell scripts (homebrew)
ipython         - Interactive computing in Python (homebrew)
jq              - Lightweight and flexible command-line JSON processor (homebrew)
neofetch        - Fast, highly customisable system info script (homebrew)
pandoc          - Swiss-army knife of markup format conversion (homebrew)
poetry          - Python package management tool (homebrew)
sl              - Prints a steam locomotive if you type sl instead of ls (homebrew)
starship        - Cross-shell prompt for astronauts (homebrew)
thefuck         - Programmatically correct mistyped console commands (homebrew)
tldr            - Simplified and community-driven man pages (homebrew)
EOF
)

