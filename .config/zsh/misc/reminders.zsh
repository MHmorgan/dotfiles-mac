
#DOC> reminders :: Look for reminders in comments of source files under cwd :: INFO
function reminders {
    local RE='(@\w+|\b(TODO|FIXME|BUG)\b)'

    # Languages with // comments
    find -E . -type f -regex ".*\.(go|java|kt|rs)$" | xargs rg "//.*$RE"

    # Languages with # comments
    find -E . -type f -regex ".*\.(pl|py|zsh)$" | xargs rg "#.*$RE"
}

