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

    install_oh_my_zsh

    # theming
    omarchy-theme-set osaka-jade >/dev/null 2>&1
}

uninstall_omarchy() {
    log "Uninstalling omarchy environment setup"
    
    # Restore removed packages (optional - user might not want these back)
    log "Note: Previously removed packages (obs-studio, obsidian, etc.) are not automatically restored"
    
    # Remove installed packages (be careful - these might be used by other applications)
    log "Note: Installed packages (zsh, firefox, stow, rsync) are not automatically removed as they might be used by other applications"
    log "If you want to remove them, run: yay -Rns zsh firefox stow rsync"
    
    # Reset shell to default (bash)
    if [[ "$SHELL" == "/usr/bin/zsh" ]]; then
        log "Resetting shell to bash..."
        chsh -s /bin/bash
    fi
    
    uninstall_oh_my_zsh
    
    # Note about theme - omarchy themes are system-wide, user should manually reset if desired
    log "Note: omarchy theme changes are not automatically reverted. Use omarchy-theme-set to change if desired"
}