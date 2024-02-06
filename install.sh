#!/bin/bash

# get directory of current script
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CWD;

# zsh
ln -svf $CWD/.zshrc $HOME/.zshrc

# powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
