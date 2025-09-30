#!/bin/bash

# Codespace environment setup and teardown functions

setup_codespace() {
    # a lot of setup is done in the container dockerfile.
    install_oh_my_zsh
    log "Setting up codespace environment"
}

