#!/bin/bash

# get directory of current script
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_BACKUP="$DOTFILES/.stow_backup"
CONFIGS="$DOTFILES/configs"

ONLY_CONFIGS=false
if [[ " $* " == *" --only-configs "* ]]; then
  ONLY_CONFIGS=true
fi

# Determine environment

# Omarchy
if [[ -d $HOME/.config/omarchy ]]; then
  ENV="omarchy"
fi

# Other environments can be added here

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

  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

setup_os() {
  git submodule update --init --recursive
  # switch on env
  case $ENV in
  omarchy)
    setup_omarchy
    ;;
  *)
    echo "Unknown environment: $ENV"
    exit 1
    ;;
  esac
}

setup_config() {
  # theming
  omarchy-theme-set osaka-jade >/dev/null 2>&1

  # mirror repo
  local TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
  local STOW_BACKUP="$STOW_BACKUP/$TIMESTAMP"
  local STOW_PKG=${CONFIGS//$DOTFILES\//}
  local EXISTING=$(cd $CONFIGS && find . -type f | cut -c3-)

  stow --verbose --target=$HOME --delete $STOW_PKG
  # backup original files first
  for f in $EXISTING; do
    local ORIGINAL="$HOME/$f"
    local TARGET="$CONFIGS/$f"
    local BACKUP_TARGET="$STOW_BACKUP/$f"

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

main() {
  if [ "$ONLY_CONFIGS" == false ]; then
    setup_os
  else
    echo "Only setting up config, skipping OS installations"
  fi
  setup_config
}

main
