#!/bin/bash

# Default values
ONLY_CONFIGS=false
# get directory of current script
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS="$DOTFILES/configs"
ENVIRONMENTS="$DOTFILES/environments"

# Source argument parsing functions
source "$DOTFILES/parse_args.sh"

# Source environment-specific functions
source "$ENVIRONMENTS/codespace.sh"
source "$ENVIRONMENTS/local.sh"
source "$ENVIRONMENTS/omarchy.sh"

OS_ENV=local
detect_environment() {
    # Environment detection logic here
    # Omarchy
    if [[ -d $HOME/.config/omarchy ]]; then
        OS_ENV="omarchy"
    fi
    if [[ "$CODESPACES" == "true" ]]; then
        OS_ENV="codespace"
    fi
}

install_oh_my_zsh() {
    if [[ ! -f "$HOME/.oh-my-zsh/oh-my-sh.sh" ]]; then
        log "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --skip-chsh
    else
        log "oh-my-zsh is already installed, skipping..."
    fi
}

setup_os() {
    # switch on env
    case $OS_ENV in
        omarchy)
            setup_omarchy
        ;;
        codespace)
            setup_codespace
        ;;
        local)
            setup_local
        ;;
        *)
            echo "Unknown environment: $OS_ENV"
            exit 1
        ;;
    esac
}

setup_config() {
    local STOW_PKG=${CONFIGS//$DOTFILES\//}
    local EXISTING=$(cd $CONFIGS && find . -type f | cut -c3-)

    stow --verbose --target=$HOME --delete $STOW_PKG
    # remove any existing conflicting files or links
    for f in $EXISTING; do
        local ORIGINAL="$HOME/$f"
        local TARGET="$CONFIGS/$f"

        if [[ -L "$ORIGINAL" ]]; then
            # remove any existing links
            log "Resetting link to $TARGET"
            rm -f $ORIGINAL
        elif [[ -f "$ORIGINAL" ]]; then
            log "Removing conflicting file: $ORIGINAL"
            # Remove the conflicting file so stow can create the symlink
            rm -f "$ORIGINAL"
        fi
    done

    # use stow to mirror the config directory
    stow --verbose --target=$HOME $STOW_PKG
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

install_command() {
    detect_environment
    log "Environment detected: $OS_ENV"
    git submodule update --init --recursive
    if [ "$ONLY_CONFIGS" == false ]; then
        log "Full installation for $OS_ENV environment"
        setup_os
    else
        log "Only setting up config, skipping OS installations"
    fi
    setup_oh_my_zsh
    setup_config
    log "Installation complete"
}

main() {
    parse_and_separate_args "$@"
    case "$COMMAND" in
        install)
            parse_install_options "${COMMAND_ARGS[@]}"
            install_command
        ;;
        *)
            echo "Error: Unknown command: $COMMAND"
            show_help
            exit 1
        ;;
    esac
}

main "$@"
