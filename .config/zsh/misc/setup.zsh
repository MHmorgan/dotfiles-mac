# Setup of a clean Mac system

#DOC> setup-system :: TODO Setup the current system [MISC]
function setup-system {
    err "NOT IMPLEMENTED"
    return 1

    header Homebrew
    if ! exists brew
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install -q $HOMEBREW_APPS
}

