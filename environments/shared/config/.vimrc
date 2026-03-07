set relativenumber

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
