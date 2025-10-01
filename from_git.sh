#!/usr/bin/env bash

# if authentication fails, there is no key in github
# if id_rsa exists, wait for the user to add it to github
# if it doesn't exist, create it and wait for the user to add it to github
# silence any response from github when checking status

KEY_FILENAME=id_rsa

main() {
  ssh -T git@github.com >/dev/null 2>&1
  ssh_exit_code=$?

  if [[ $ssh_exit_code != 1 ]]; then
    echo "GitHub authentication failed"
    exit 1
  fi

  git clone -b v2 --recurse-submodules https://github.com/Nvveen/dotfiles

}

main "$@"
