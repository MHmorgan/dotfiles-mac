#!/usr/bin/env zsh
# vim: filetype=zsh:tabstop=4:shiftwidth=4:expandtab:

#  _____           
# |  ___|__   ___  
# | |_ / _ \ / _ \ 
# |  _| (_) | (_) |
# |_|  \___/ \___/ 
#                  

#{{{ The 7 helpers
autoload -U colors && colors
function info   { echo "\e[${color[faint]};${color[default]}m$*$reset_color" }
function warn   { echo "$fg_bold[yellow]WARN: $*$reset_color" }
function err    { echo "$fg_bold[red]ERROR: $*$reset_color" }
function bail   { err $* ; exit 1 }
function bold   { echo "$fg_bold[default]$*$reset_color" }
function exists { which $* &>/dev/null }
function header { gum style --border=rounded --width=20 --align=center --margin="1 0" "$*" }
#}}}


zparseopts -D \
    h=HELP -help=HELP \
    q=QUIET -quiet=QUIET


[[ -n "$HELP" ]] && cat <<EOF
Usage: foo [options]

Options:
    --help -h
            Print this help message.
    --quiet -q
            Print less output.
EOF

