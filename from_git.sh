#!/usr/bin/env bash

main() {
  git clone -b v2 --recurse-submodules https://github.com/Nvveen/dotfiles
  cd dotfiles
  bash setup.sh install
}

main "$@"
