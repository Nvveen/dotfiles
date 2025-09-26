#!/bin/bash

# Default values
VERBOSE=false
ONLY_CONFIGS=false
# get directory of current script
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_BACKUP="$DOTFILES/.stow_backup"
CONFIGS="$DOTFILES/configs"

OS_ENV=local
detect_environment() {
    # Environment detection logic here
    # Omarchy
    if [[ -d $HOME/.config/omarchy ]]; then
        OS_ENV="omarchy"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log "oh-my-zsh is already installed, skipping..."
    fi
}

setup_local() {
    echo "Setting up local environment"
    install_oh_my_zsh
    # Local setup logic here
}

setup_omarchy() {
    # install packages
    yay -S --noconfirm zsh firefox stow rsync
    chsh -s /usr/bin/zsh

    # Remove packages
    yay -Rns obs-studio obsidian xournalpp typora omarchy-chromium
    declare -a WEBAPPS=(Basecamp ChatGPT Figma HEY Zoom)
    for pkg in "${WEBAPPS[@]}"; do
        omarchy-webapp-remove $pkg
    done

    install_oh_my_zsh
}

setup_os() {
    # switch on env
    case $OS_ENV in
        omarchy)
            setup_omarchy
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
    # theming
    omarchy-theme-set osaka-jade >/dev/null 2>&1

    # mirror repo
    local TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
    local STOW_BACKUP_DIR="$STOW_BACKUP/$TIMESTAMP"
    local STOW_PKG=${CONFIGS//$DOTFILES\//}
    local EXISTING=$(cd $CONFIGS && find . -type f | cut -c3-)

    stow --verbose --target=$HOME --delete $STOW_PKG
    # backup original files first
    for f in $EXISTING; do
        local ORIGINAL="$HOME/$f"
        local TARGET="$CONFIGS/$f"
        local BACKUP_TARGET="$STOW_BACKUP_DIR/$f"

        # stow --delete $CONFIGS
        if [[ -L "$ORIGINAL" ]]; then
            # remove any existing links
            echo "Resetting link to $TARGET"
            rm -f $ORIGINAL
        else
            echo "Backing up $ORIGINAL to $BACKUP_TARGET"
            install -D "$TARGET" "$BACKUP_TARGET" >/dev/null 2>&1
        fi
    done

    stow --verbose --target=$HOME --adopt $STOW_PKG

    # use stow to mirror the config directory
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] COMMAND [ARGS]

Commands:
    install     Install the application
    uninstall   Uninstall the application

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    --only-configs      Install only configuration files (install command only)
    --env <ENV>         Override environment detection (omarchy, local)

Examples:
    $0 install
    $0 install --only-configs
    $0 uninstall --verbose
    $0 install --env docker
EOF
}

log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

install_command() {
    detect_environment
    echo "Environment detected: $OS_ENV"
    if [ "$ONLY_CONFIGS" == false ]; then
        log "Full installation for $OS_ENV environment"
        setup_os
    else
        echo "Only setting up config, skipping OS installations"
    fi
    setup_config
    echo "Installation complete"
}

uninstall_command() {
    log "Starting uninstall"
    # Uninstall logic here
    echo "Uninstall complete"
}

main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
            ;;
            -v|--verbose)
                VERBOSE=true
                shift
            ;;
            --only-configs)
                ONLY_CONFIGS=true
                shift
            ;;
            --env)
                OS_ENV="$2"
                shift 2
            ;;
            install|uninstall)
                COMMAND="$1"
                shift
                break
            ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
            ;;
        esac
    done

    # Execute command
    case "${COMMAND:-}" in
        install)
            install_command "$@"
        ;;
        uninstall)
            uninstall_command "$@"
        ;;
        *)
            echo "Error: Unknown command: $COMMAND"
            show_help
            exit 1
        ;;
    esac
}

main "$@"
