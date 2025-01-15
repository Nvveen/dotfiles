#!/bin/bash

# get directory of current script
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CWD;

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
ln -svf $CWD/.zshrc $HOME/.zshrc

# powerlevel10k
ln -svf $CWD/.p10k.zsh $HOME/.p10k.zsh

# powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# powerlevel10k theme
git clone https://github.com/romkatv/powerlevel10k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
