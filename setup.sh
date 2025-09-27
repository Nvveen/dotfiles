#!/bin/bash

# Default values
VERBOSE=false
ONLY_CONFIGS=false
RESTORE_BACKUP=""
NO_UPDATE=false
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
    if [[ "$CODESPACES" == "true" ]]; then
        OS_ENV="codespace"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --skip-chsh
    else
        log "oh-my-zsh is already installed, skipping..."
    fi
}

setup_codespace() {
    # a lot of setup is done in the container dockerfile.
    install_oh_my_zsh
    echo "Setting up codespace environment"
}

setup_local() {
    echo "Setting up local environment"
}

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
    # mirror repo
    local TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
    local STOW_BACKUP_DIR="$STOW_BACKUP/$TIMESTAMP"
    local STOW_PKG=${CONFIGS//$DOTFILES\//}
    local EXISTING=$(cd $CONFIGS && find . -type f | cut -c3-)

    stow --verbose --target=$HOME --delete $STOW_PKG
    # backup original target files first (to prevent --adopt from overwriting our source)
    for f in $EXISTING; do
        local ORIGINAL="$HOME/$f"
        local TARGET="$CONFIGS/$f"
        local BACKUP_TARGET="$STOW_BACKUP_DIR/$f"

        if [[ -L "$ORIGINAL" ]]; then
            # remove any existing links
            echo "Resetting link to $TARGET"
            rm -f $ORIGINAL
        elif [[ -f "$ORIGINAL" ]]; then
            echo "Backing up $ORIGINAL to $BACKUP_TARGET"
            install -D "$ORIGINAL" "$BACKUP_TARGET" >/dev/null 2>&1
            # Remove the conflicting file so --adopt won't overwrite our source
            rm -f "$ORIGINAL"
        fi
    done

    # use stow to mirror the config directory
    stow --verbose --target=$HOME $STOW_PKG
}

show_help() {
    cat << EOF
Usage: $0 [GLOBAL_OPTIONS] COMMAND [COMMAND_OPTIONS]

Commands:
    install       Install the application
    uninstall     Uninstall the application
    list-backups  List available backup timestamps

Global Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    --no-update         Skip checking for updates from GitHub

Command-Specific Options:

  install:
    --only-configs      Install only configuration files
    --env <ENV>         Override environment detection (omarchy, local, codespace)

  uninstall:
    --restore <DATE>    Restore specific backup during uninstall

  list-backups:
    (no specific options)

Examples:
    $0 install
    $0 install --only-configs
    $0 install --env omarchy
    $0 uninstall --verbose
    $0 uninstall --restore 2023-10-15T14:30:22
    $0 list-backups
    $0 --no-update install
EOF
}

log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

check_for_updates() {
    log "Checking for updates from GitHub repository..."
    
    # Check if we're in a git repository
    if [[ ! -d "$DOTFILES/.git" ]]; then
        log "Not in a git repository, skipping update check"
        return 0
    fi
    
    # Check if we have internet connectivity
    if ! curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
        log "No internet connection, skipping update check"
        return 0
    fi
    
    # Fetch latest changes from remote
    log "Fetching latest changes from remote..."
    cd "$DOTFILES" || {
        echo "Error: Could not change to dotfiles directory"
        return 1
    }
    
    # Get current commit hash
    local current_commit=$(git rev-parse HEAD)
    
    # Fetch from remote (don't merge yet)
    if ! git fetch origin 2>/dev/null; then
        log "Failed to fetch from remote, continuing with current version"
        return 0
    fi
    
    # Get remote commit hash for current branch
    local current_branch=$(git branch --show-current)
    local remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null)
    
    # If we can't get remote commit, skip update
    if [[ -z "$remote_commit" ]]; then
        log "Could not determine remote commit, skipping update"
        return 0
    fi
    
    # Check if we're behind
    if [[ "$current_commit" != "$remote_commit" ]]; then
        echo "Updates found in GitHub repository!"
        echo "Current commit: ${current_commit:0:8}"
        echo "Remote commit:  ${remote_commit:0:8}"
        echo
        
        # Check if there are local changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo "Warning: You have local changes that haven't been committed."
            echo "The update will be skipped to avoid conflicts."
            echo "Please commit or stash your changes and run the script again."
            return 1
        fi
        
        echo "Pulling updates and restarting script..."
        
        # Pull the updates
        if git pull origin "$current_branch"; then
            echo "Updates applied successfully. Restarting script..."
            echo "----------------------------------------"
            
            # Re-execute the script with the same arguments
            exec "$0" "$@"
        else
            echo "Error: Failed to pull updates"
            echo "Continuing with current version..."
            return 1
        fi
    else
        log "Script is up to date"
    fi
    
    return 0
}

install_command() {
    detect_environment
    echo "Environment detected: $OS_ENV"
    # make sure submodules have been pulled in
    git submodule update --init --recursive
    if [ "$ONLY_CONFIGS" == false ]; then
        log "Full installation for $OS_ENV environment"
        setup_os
    else
        echo "Only setting up config, skipping OS installations"
    fi
    setup_config
    echo "Installation complete"
}

uninstall_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Uninstalling oh-my-zsh..."
        # Run oh-my-zsh uninstall script if it exists
        if [[ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]]; then
            env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/uninstall.sh" --remove-config
        else
            # Manual cleanup if uninstall script doesn't exist
            log "Manually removing oh-my-zsh directory..."
            rm -rf "$HOME/.oh-my-zsh"
        fi
        log "oh-my-zsh uninstalled"
    else
        log "oh-my-zsh not found, skipping..."
    fi
}

uninstall_codespace() {
    log "Uninstalling codespace environment setup"
    uninstall_oh_my_zsh
}

uninstall_local() {
    log "Uninstalling local environment setup"
    # Local setup currently does nothing, so nothing to uninstall
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

uninstall_os() {
    detect_environment
    log "Uninstalling OS-specific setup for $OS_ENV environment"

    # Switch on env
    case $OS_ENV in
        omarchy)
            uninstall_omarchy
        ;;
        codespace)
            uninstall_codespace
        ;;
        local)
            uninstall_local
        ;;
        *)
            echo "Unknown environment: $OS_ENV"
            exit 1
        ;;
    esac
}

uninstall_config() {
    log "Uninstalling configuration files..."

    local STOW_PKG=${CONFIGS//$DOTFILES\//}
    local EXISTING=$(cd $CONFIGS && find . -type f | cut -c3-)

    # Use stow to remove symlinks
    log "Removing symlinked configuration files..."
    stow --verbose --target=$HOME --delete $STOW_PKG 2>/dev/null || {
        log "Warning: Some stow operations failed. This is normal if some files were already removed."
    }

    # Handle backup restoration
    if [[ -d "$STOW_BACKUP" ]]; then
        local BACKUP_TO_RESTORE=""

        if [[ -n "$RESTORE_BACKUP" ]]; then
            # User specified a specific backup
            if [[ -d "$STOW_BACKUP/$RESTORE_BACKUP" ]]; then
                BACKUP_TO_RESTORE="$RESTORE_BACKUP"
                log "Using specified backup: $RESTORE_BACKUP"
            else
                log "Error: Specified backup '$RESTORE_BACKUP' not found"
                log "Available backups:"
                ls -1 "$STOW_BACKUP" 2>/dev/null || echo "  (none)"
                exit 1
            fi
        else
            # Find and offer the most recent backup
            local LATEST_BACKUP=$(ls -1t "$STOW_BACKUP" 2>/dev/null | head -1)
            if [[ -n "$LATEST_BACKUP" ]] && [[ -d "$STOW_BACKUP/$LATEST_BACKUP" ]]; then
                log "Found backup from $LATEST_BACKUP"
                echo "Available backups:"
                ls -1t "$STOW_BACKUP" 2>/dev/null | head -5
                echo
                read -p "Do you want to restore backed up files from $LATEST_BACKUP? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    BACKUP_TO_RESTORE="$LATEST_BACKUP"
                fi
            else
                log "No valid backups found to restore"
            fi
        fi

        # Restore the selected backup
        if [[ -n "$BACKUP_TO_RESTORE" ]]; then
            log "Restoring backed up files from $BACKUP_TO_RESTORE..."
            cp -r "$STOW_BACKUP/$BACKUP_TO_RESTORE"/. "$HOME/"
            log "Backup files restored"
        else
            log "Skipping backup restoration"
        fi
    else
        log "No backup directory found"
    fi

    # List files that were managed by this dotfiles setup
    log "The following files were managed by this dotfiles setup:"
    for f in $EXISTING; do
        if [[ -L "$HOME/$f" ]] || [[ -f "$HOME/$f" ]]; then
            echo "  $HOME/$f"
        fi
    done

    log "Configuration uninstall complete"
}

uninstall_command() {
    log "Starting uninstall process..."

    echo "This will remove dotfiles configuration and potentially some installed software."
    echo "Backups will be offered where available."
    echo
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Uninstall cancelled by user"
        exit 0
    fi

    # Always uninstall config first
    uninstall_config

    # Only uninstall OS setup if it wasn't --only-configs install
    if [ "$ONLY_CONFIGS" == false ]; then
        uninstall_os
    else
        log "Skipping OS-specific uninstall (only configs were installed)"
    fi

    log "Uninstall complete!"
    echo
    echo "Notes:"
    echo "- Some system packages were not automatically removed for safety"
    echo "- Shell may have been reset to bash (restart terminal to take effect)"
    echo "- Check the backup directory if you need to recover any files: $STOW_BACKUP"
}

list_backups_command() {
    if [[ -d "$STOW_BACKUP" ]]; then
        echo "Available backups (newest first):"
        ls -1t "$STOW_BACKUP" 2>/dev/null | while read backup; do
            echo "  $backup"
            # Show some info about what's in the backup
            local file_count=$(find "$STOW_BACKUP/$backup" -type f 2>/dev/null | wc -l)
            echo "    ($file_count files backed up)"
        done
    else
        echo "No backup directory found at: $STOW_BACKUP"
    fi
}

parse_global_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
            ;;
            --no-update)
                NO_UPDATE=true
                shift
            ;;
            *)
                if [[ -n "$1" ]]; then
                    echo "Error: Unknown global option: $1"
                    echo "Use -h or --help for usage information"
                    exit 1
                fi
                shift
            ;;
        esac
    done
}

parse_install_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --only-configs)
                ONLY_CONFIGS=true
                shift
            ;;
            --env)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --env requires a value"
                    exit 1
                fi
                OS_ENV="$2"
                shift 2
            ;;
            *)
                echo "Error: Unknown install option: $1"
                echo "Valid install options: --only-configs, --env <ENV>"
                exit 1
            ;;
        esac
    done
}

parse_uninstall_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restore)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --restore requires a backup timestamp"
                    exit 1
                fi
                RESTORE_BACKUP="$2"
                shift 2
            ;;
            *)
                echo "Error: Unknown uninstall option: $1"
                echo "Valid uninstall options: --restore <DATE>"
                exit 1
            ;;
        esac
    done
}

parse_list_backups_options() {
    if [[ $# -gt 0 ]]; then
        echo "Error: list-backups command does not accept any options"
        echo "Usage: $0 list-backups"
        exit 1
    fi
}

main() {
    # Handle help first
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    # Check for --no-update flag first (before calling check_for_updates)
    for arg in "$@"; do
        if [[ "$arg" == "--no-update" ]]; then
            NO_UPDATE=true
            break
        fi
    done

    # Check for updates before doing anything else (unless --no-update is specified)
    if [[ "$NO_UPDATE" != true ]]; then
        check_for_updates "$@"
    fi

    # Find command first, then parse options
    local args=("$@")
    local command_found=false
    local global_args=()
    local command_args=()
    local in_command=false

    for arg in "${args[@]}"; do
        if [[ "$arg" == "install" || "$arg" == "uninstall" || "$arg" == "list-backups" ]]; then
            COMMAND="$arg"
            command_found=true
            in_command=true
            continue
        fi

        if [[ "$in_command" == false ]]; then
            global_args+=("$arg")
        else
            command_args+=("$arg")
        fi
    done

    # If no command found
    if [[ "$command_found" == false ]]; then
        echo "Error: No command specified"
        show_help
        exit 1
    fi

    # Parse global options
    parse_global_options "${global_args[@]}"

    # Parse command-specific options
    case "$COMMAND" in
        install)
            parse_install_options "${command_args[@]}"
            install_command
        ;;
        uninstall)
            parse_uninstall_options "${command_args[@]}"
            uninstall_command
        ;;
        list-backups)
            parse_list_backups_options "${command_args[@]}"
            list_backups_command
        ;;
        *)
            echo "Error: Unknown command: $COMMAND"
            show_help
            exit 1
        ;;
    esac
}

main "$@"
