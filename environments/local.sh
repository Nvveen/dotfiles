#!/bin/bash

# Local environment setup and teardown functions

setup_local() {
    log "Setting up local environment"
    install_oh_my_zsh
}

uninstall_local() {
    log "Uninstalling local environment setup"
    # Local setup currently does nothing, so nothing to uninstall
}