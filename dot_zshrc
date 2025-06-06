#!/bin/sh

# Prevent Ubuntu from performing useless overhead
skip_global_compinit=1

setopt nobeep
unsetopt nomatch

SAVEHIST=1000
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
setopt appendhistory
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

ZSH="$HOME/.zsh"
ZSH_CACHE_DIR="$HOME/.zsh_cache"

ZREPOS="$ZSH/repos"

[[ -r "$ZREPOS/znap/znap.zsh" ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git "$ZREPOS/znap"

source "$ZREPOS/znap/znap.zsh"

zstyle ":znap:*" repos-dir $ZREPOS

znap eval starship "starship init zsh --print-full-init"
znap prompt

zstyle ":autocomplete:*" insert-unambiguous yes
zstyle ":autocomplete:*" widget-style menu-select

zstyle ":autocomplete:history-search:*" list-lines 16
zstyle ":autocomplete:history-incremental-search-*:*" list-lines 16  

znap source marlonrichert/zsh-edit
bindkey -M emacs -r '^[/' \
                    '^[Y'

znap source marlonrichert/zsh-autocomplete
bindkey '\t' menu-select "$terminfo[kcbt]" reverse-menu-complete

znap clone junegunn/fzf
source "$ZSH/scripts/fzf.zsh"

zle -N up-line-or-search
up-line-or-search() {
  if [[ $LBUFFER == *$'\n'* ]] then
    zle up-line
  else
    fzf-history-widget
  fi
}

# bindkey -M menuselect '\r' .accept-line

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
znap source zsh-users/zsh-autosuggestions

znap eval dircolors "dircolors $HOME/.dircolors"
znap eval mise "mise activate zsh"

# Don't try to ssh to hosts file
zstyle ":completion:*" hosts off
zstyle ":completion:*:*:git:*" script "$ZSH/scripts/git-completion.bash"

source "$ZSH/custom.zsh"

fpath+=($ZSH/completions)

znap fpath _glab      "glab      completion  -s zsh"
znap fpath _kubectl   "kubectl   completion  zsh"
znap fpath _remotectl "remotectl completion  zsh"
znap fpath _mise      "mise      completion  zsh"
znap fpath _starship  "starship  completions zsh"

ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main brackets regexp)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=#83A598'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=green'

znap source zsh-users/zsh-syntax-highlighting

