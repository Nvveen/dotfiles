#!/usr/bin/env bash

# if authentication fails, there is no key in github
# if id_rsa_github exists, wait for the user to add it to github
# if it doesn't exist, create it and wait for the user to add it to github
# silence any response from github when checking status

main() {
  ssh -T git@github.com >/dev/null 2>&1
  ssh_exit_code=$?

  if [[ $ssh_exit_code == 1 ]]; then
    echo "GitHub authentication successful"
  else
    if [[ -f "$HOME/.ssh/id_rsa_github" ]]; then
      echo "Please add your SSH key to GitHub:"
      echo ""
      cat $HOME/.ssh/id_rsa_github.pub
      echo ""
      read -p "Press [Enter] after adding the key to GitHub" </dev/tty
    else
      echo "Creating a new SSH key for GitHub..."
      ssh-keygen -t rsa -b 4096 -C "nealvanveen@gmail.com" -f $HOME/.ssh/id_rsa_github -N ""
      echo "Please add your SSH key to GitHub:"
      echo ""
      cat $HOME/.ssh/id_rsa_github.pub
      echo ""
      read -p "Press [Enter] after adding the key to GitHub" </dev/tty
    fi

    eval "$(ssh-agent -s)"
    ssh-add $HOME/.ssh/id_rsa_github
    echo "SSH key added to ssh-agent"

    ssh -T git@github.com >/dev/null 2>&1
    ssh_exit_code=$?
    if [[ $ssh_exit_code != 1 ]]; then
      echo "GitHub authentication failed. Exiting."
      exit 1
    fi
  fi

  git clone -b v2 git@github.com:Nvveen/dotfiles.git

}

main "$@"
