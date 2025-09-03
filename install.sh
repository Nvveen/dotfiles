#!/bin/bash

# get directory of current script
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $CWD

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
ln -svf $CWD/.zshrc $HOME/.zshrc

git submodule update --init --recursive

# link plugins
ln -svf $CWD/modules/.oh-my-zsh/custom/plugins/* $HOME/.oh-my-zsh/custom/plugins/
