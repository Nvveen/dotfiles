#!/bin/bash

# Omarchy environment setup and teardown functions

setup_omarchy() {
    # install packages
    yay -Sy --noconfirm zsh firefox stow rsync
    chsh -s /usr/bin/zsh

    # Remove packages
    yay -Rns --noconfirm obs-studio obsidian xournalpp typora omarchy-chromium
    declare -a WEBAPPS=(Basecamp ChatGPT Figma HEY Zoom)
    for pkg in "${WEBAPPS[@]}"; do
        omarchy-webapp-remove $pkg
    done

    # theming
    omarchy-theme-set osaka-jade >/dev/null 2>&1
}

