#! /bin/bash

alias zshenv="$EDITOR ~/.zshenv"
alias zshrc="$EDITOR ~/.zshrc"

# File system
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons'
alias la='ll -a'
alias lt='eza -l --sort accessed --icons'
alias lta='lt -a'
alias ltr='lt -r'
alias ltra='ltr -a'
alias tree='eza --tree --level=2 --long --icons --git'

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

# git
alias gs='git status'
alias gdh='git diff HEAD'
alias gdm='git diff master'
alias gdd='git diff develop'
alias gpu='git push -u'
alias gbm='git branch -m'
alias gsl='git stash list'

alias grho='git reset --hard @{upstream}'
alias gcf='git commit --fixup'

# Delete merged branches on master
alias gbdm='git branch --merged | egrep -v "(^\*|master|production)" | xargs -r -n 1 git branch -d'

# Change $TARGET_BRANCH to your targeted branch, e.g. change from `master` to `main` to delete branches squashed into `main`.
alias gbdms='git checkout -q master && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base master $branch) && [[ $(git cherry master $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done'

alias gsync='git fetch && git pull && gbdm && gbdms && git remote prune origin'
alias gclean='git reset --hard && git clean -fd'

# mix
alias mt='mix test'
alias mtw='mix test.watch'
alias mpr='mix phx.routes'
alias mps='mix phx.server'

# aliases
alias rtx=mise

alias localtunnel="$HOME/.local/bin/lt"

alias qmku="cd $HOME/code/qmk_userspace"
alias qmkf="cd $HOME/code/qmk_firmware"

alias nvl="NVIM_APPNAME=nvim-lazy nvim"

# chezmoi
alias dot="chezmoi cd"

alias cm="chezmoi"
alias cmall="chezmoi add $HOME/.config/nvim/lazy-lock.json"
alias cma="cmall && chezmoi apply"
alias cmd="cmall && chezmoi diff"
alias cme="chezmoi edit"
alias cmf="chezmoi forget"

alias nvc="c $HOME/.config/nvim"
