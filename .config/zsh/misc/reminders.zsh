
#DOC> reminders :: Look for reminders in comments of source files under cwd :: INFO
function reminders {
    # Languages with // comments
    find -E . -type f -regex ".*\.(go|java|kt|rs)$" | xargs rg '//.*(@\w+|\b(TODO|FIXME|BUG)\b)'

    # Languages with # comments
    find -E . -type f -regex ".*\.(pl|py|zsh)$" | xargs rg '#.*(@\w+|\(TODO|FIXME|BUG)\b)'
}

