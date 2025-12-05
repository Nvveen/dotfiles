#!/bin/bash

setup_codespace() {
    sudo apt update && sudo apt install -y \
        vim \
        starship \
        stow
    log "Setting up codespace environment"
}

