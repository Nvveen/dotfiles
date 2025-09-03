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
    sudo yay -S --noconfirm zsh

    # oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ln -svf $CWD/.zshrc $HOME/.zshrc

    # link plugins
    ln -svf $CWD/modules/.oh-my-zsh/custom/plugins/* $HOME/.oh-my-zsh/custom/plugins/
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
