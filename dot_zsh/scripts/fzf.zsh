#! /bin/bash

if [ ! $(command -v fzf) ]; then
  ~[junegunn/fzf]/install --bin
  cp ~[junegunn/fzf]/bin/fzf "$HOME_LOCAL_PATH"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source ~[junegunn/fzf]/shell/completion.zsh 2> /dev/null

# Key bindings
# ------------
source ~[junegunn/fzf]/shell/key-bindings.zsh
