#!/bin/bash

rm -f ~/{.zshrc,.p10k.zsh}

rm -rf ~/.oh-my-zsh

rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/*
