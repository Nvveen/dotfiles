#!/bin/bash

setup_codespace() {
    sudo apt update && sudo apt install -y \
        vim \
        starship \
        stow \
        zsh
    sudo chsh $(whoami) -s $(which zsh)
    mkdir -p ~/.ssh
    log "Setting up codespace environment"
}

