set relativenumber

if filereadable(expand("~/.local/custom/.vimrc.local"))
  source ~/.local/custom/.vimrc.local
endif
