#!/bin/bash

setup_codespace() {
    # make sure ubuntu universe is enabled
    sudo add-apt-repository universe -y
    sudo apt update && sudo apt install -y \
        vim \
        starship \
        stow \
        zsh
    sudo chsh $(whoami) -s $(which zsh)
    mkdir -p ~/.ssh
    log "Setting up codespace environment"
}

