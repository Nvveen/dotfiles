#!/bin/bash

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
  yay -S --noconfirm zsh firefox
  chsh -s /usr/bin/zsh

  # Remove packages
  yay -Rns obs-studio obsidian xournalpp typora omarchy-chromium
  declare -a WEBAPPS=(Basecamp ChatGPT Figma HEY Zoom)
  for pkg in "${WEBAPPS[@]}"; do
    rm -vf "$HOME/.local/share/applications/${pkg}.desktop"
    rm -vf "$HOME/.local/share/applications/icons/${pkg}.png"
  done

  # oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ln -svf $CWD/zsh/zshrc $HOME/.zshrc
  ln -svf $CWD/zsh/zprofile $HOME/.zprofile
  ln -svf $CWD/oh-my-zsh/aliases.sh $ZSH_CUSTOM/aliases.sh

  # starship theme
  mv -v $HOME/.config/starship.toml $HOME/.config/starship.toml_bak
  starship preset tokyo-night -o $HOME/.config/starship.toml

  # link plugins
  plugins_dir="$CWD/oh-my-zsh/custom/plugins"
  ls $plugins_dir | while read -r line; do
    ln -svf "$plugins_dir/$line" "$HOME/.oh-my-zsh/custom/plugins/$line"
  done

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
