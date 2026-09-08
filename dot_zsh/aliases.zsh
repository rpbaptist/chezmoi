#! /bin/bash

alias zshenv="$EDITOR ~/.zshenv"
alias zshrc="$EDITOR ~/.zshrc"

# File system
# --icons takes an optional value, so a bare --icons greedily swallows the next
# word as its argument (e.g. `ll somefile` errors); pin it with --icons=auto
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -l --group-directories-first --icons=auto'
alias la='ll -a'
alias lt='eza -l --sort accessed --icons=auto'
alias lta='lt -a'
alias ltr='lt -r'
alias ltra='ltr -a'
alias tree='eza --tree --level=2 --long --icons=auto --git'

# system _eza completion (/usr/share/zsh/site-functions/_eza) has a broken option spec
# ("--color=[...]:(when):(...)") that breaks completion for every eza-based alias; use plain file completion instead
compdef _files eza

alias sudo="sudo "
alias sl="subl"
alias nv="nvim"
alias scp="noglob scp"
alias lab="glab"
alias code="code --goto"

# I want to use gs for "git status"
alias ghostscript="/usr/bin/gs"
# alias toclip="xclip -sel clip <"

alias ssh="kitty +kitten ssh"

# Save files, save lives
alias tp="trash-put"
alias rm='echo "Careful now!"; false'

alias dockerprune='docker rmi $(docker images -f "dangling=true" -q)'

# mix
alias mt='mix test'
alias mtw='mix test.watch'
alias mpr='mix phx.routes'
alias mps='mix phx.server'

alias localtunnel="$HOME/.local/bin/lt"

alias qmku="cd $HOME/code/qmk_userspace"
alias qmkf="cd $HOME/code/qmk_firmware"

# chezmoi
alias dot="chezmoi cd"

alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmd="chezmoi diff"
alias cme="chezmoi edit"
alias cmf="chezmoi forget"

alias nvc="cd $HOME/.config/nvim"

# unalias c

alias oc=opencode
alias cl=claude
alias clx=claude --allow-dangerously-skip-permissions

# ruby

alias bi="bundle install"
alias be="bundle exec"
alias bb="bundle binstubs"
