#!/bin/bash

# TODO hyprland bindings
# TODO alacritty config

# get directory of current script
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $CWD

git submodule update --init --recursive

# Determine environment

# Omarchy
if [[ -d $HOME/.config/omarchy ]]; then
  ENV="omarchy"
fi

# Other environments can be added here

setup_omarchy() {
  # install packages
  yay -S --noconfirm zsh firefox stow
  chsh -s /usr/bin/zsh

  # Remove packages
  yay -Rns obs-studio obsidian xournalpp typora omarchy-chromium
  declare -a WEBAPPS=(Basecamp ChatGPT Figma HEY Zoom)
  for pkg in "${WEBAPPS[@]}"; do
    omarchy-webapp-remove $pkg
  done

  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # mirror repo

  # theming
  omarchy-theme-set osaka-jade
}

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
