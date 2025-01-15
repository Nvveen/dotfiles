#!/bin/bash

rm -f ~/{.zshrc,.p10k.zsh}

rm -rf ~/.oh-my-zsh

rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
