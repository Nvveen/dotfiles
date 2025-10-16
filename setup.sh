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
# Note: These will be sourced dynamically based on detected environment
# to support the new environments/${ENV}/setup.sh structure

OS_ENV=local
detect_environment() {
    if [[ -d $HOME/.config/omarchy ]]; then
        OS_ENV="omarchy"
    fi
    if [[ "$CODESPACES" == "true" ]]; then
        OS_ENV="codespace"
    fi
    if [[ "$NEALARCH" == "true" ]]; then
        OS_ENV="nealarch"
    fi
}

install_oh_my_zsh() {
    rm -rf ~/.oh-my-zsh
    log "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --skip-chsh
    rm -f ~/.zshrc  # Remove the default .zshrc created by oh-my-zsh
}

setup_os() {
    local ENV_SETUP_SCRIPT="$ENVIRONMENTS/$OS_ENV/setup.sh"

    if [[ -f "$ENV_SETUP_SCRIPT" ]]; then
        log "Sourcing environment setup script: $ENV_SETUP_SCRIPT"
        source "$ENV_SETUP_SCRIPT"

        # Call the environment-specific setup function
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
            nealarch)
                setup_nealarch
            ;;
            *)
                echo "Unknown environment: $OS_ENV"
                exit 1
            ;;
        esac
    else
        echo "Error: Environment setup script not found: $ENV_SETUP_SCRIPT"
        exit 1
    fi
}

setup_config() {
    local SHARED_DIR="$DOTFILES/environments/shared"
    local ENV_CONFIG_DIR="$DOTFILES/environments/$OS_ENV"

    # Clean up any existing stowed configs first
    if [[ -d "$SHARED_DIR/config" ]]; then
        cd "$SHARED_DIR"
        stow --verbose --target=$HOME --delete config 2>/dev/null || true
        cd "$DOTFILES"
    fi
    if [[ -d "$ENV_CONFIG_DIR/config" ]]; then
        cd "$ENV_CONFIG_DIR"
        stow --verbose --target=$HOME --delete config 2>/dev/null || true
        cd "$DOTFILES"
    fi

    # First, stow shared configs as the base
    if [[ -d "$SHARED_DIR/config" ]]; then
        log "Installing shared configs..."
        cd "$SHARED_DIR"
        stow --verbose --target=$HOME --restow --adopt config
        git restore .
        cd "$DOTFILES"
    else
        log "Warning: No shared configs found at $SHARED_DIR/config"
    fi

    # Then, stow environment-specific configs (overrides shared symlinks)
    if [[ -d "$ENV_CONFIG_DIR/config" ]]; then
        log "Installing $OS_ENV config overrides..."
        cd "$ENV_CONFIG_DIR"
        stow --verbose --target=$HOME --restow --adopt config
        git restore .
        cd "$DOTFILES"
    else
        log "No $OS_ENV-specific configs found, using shared only"
    fi
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
    install_oh_my_zsh
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
