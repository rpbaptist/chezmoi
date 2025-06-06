#! /bin/bash

function source-plugin() {
  local plugin

  plugin="$1"

  source "$ZSH_PLUGINS/$plugin/$plugin.plugin.zsh"
}

# function mysql-restore() {
#     (
#         echo "SET AUTOCOMMIT=0;"
#         echo "SET UNIQUE_CHECKS=0;"
#         echo "SET FOREIGN_KEY_CHECKS=0;"
#         cat "$1"
#         echo "SET FOREIGN_KEY_CHECKS=1;"
#         echo "SET UNIQUE_CHECKS=1;"
#         echo "SET AUTOCOMMIT=1;"
#         echo "COMMIT;"
#     ) | mysql -u root -h 127.0.0.1 -p "$2"
# }

#
# Some usefull kubectl commands
#
#
# fg-bg toggle via c-z
function fg-bg {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER=fg
        zle accept-line
    else
        zle push-input
    fi
}
zle -N fg-bg
bindkey '^z' fg-bg

function kube-find-namespace() {
  kubectl get namespaces | tail -n +2 | fzf -q "$1" | awk '/(.*)/ {print $1}'
}

function kube-pod() {
  local namespace
  local pod_type
  namespace="$1"
  pod_type="$2"
  kubectl get pods -n "$namespace" | awk -v pattern=".+-$pod_type-.+Running" '$0 ~ pattern {print $1}' | head -n 1
}

function kube() {
  local cmd
  local pod_type
  local namespace
  cmd="$1"
  pod_type="$2"
  namespace="$(kube-find-namespace "$3")"
  pod="$(kube-pod "$namespace" "$pod_type")"

  case "$cmd" in
    "rc")  echo "Dropping into rails console on $pod in $namespace"
           kubectl exec -it "$pod" -n "$namespace" -- rails c;;
    "ssh") echo "Dropping into shell on $pod in $namespace"
           kubectl exec -it "$pod" -n "$namespace" -- bash;;
    "log") echo "Tailing logs on $pod in $namespace"
           kubectl logs "$pod" -n "$namespace" -f;;
  esac
}

function git-get-branch() {
  git branch -vv | fzf -q "$1" | awk '/(.*)/ {print $1}'
}

function gcof() {
  local branch
  branch="$(git-get-branch "$1")"

  git checkout "$branch"
}

# git

function grbi() {
  local commit_hash
  if [ -z "$1" ]
  then
  # First commit of the branch
    commit_hash="$(git cherry master -v | head -1 |  awk '{split($0,a," "); print a[2]}')^"
  else
    commit_hash=$1
  fi
  git rebase -i "$commit_hash"
}

function gcfr() {
  git commit --fixup "$1" && git rebase -i "$1^"
}

function ff() {
  if [ -z "$1" ]
  then
    fzf --preview 'bat --style=numbers --color=always {}'
  else
    fzf --preview 'bat --style=numbers --color=always {}' -q "$1" 
   fi
}

function mf() {
  if [ -z "$1" ]
  then
    git ls-files --other --modified --exclude-standard | xargs mix format
  else
    mix format "$1"
  fi
}

function find-note() {
  find "$NOTES_PATH" -type f -name "*.md" | awk -F "$NOTES_PATH/" '{print $2}' | fzf --preview 'bat--style=numbers --color=always {}' -q "$1" 
}

function notes() {
  cd $NOTES_PATH
  if [ -z "$1" ]
  then
    $EDITOR -n "$NOTES_PATH"
  else
    local file
    file="$(find-note "$1")"
    $EDITOR -n "$NOTES_PATH" "$NOTES_PATH/$file"
  fi
}

function note() {
  local file
  file="$(find-note "$1")"
  cd "$NOTES_PATH"
  if [ -z "$file" ]
  then 
    mkdir -p $( dirname "$1")
    touch "$1"
    $EDITOR "$NOTES_PATH/$1"
  else
    $EDITOR "$NOTES_PATH/$file"
  fi
}

# function shorthand-find-function() {
#   local path
#   local name
#   local type
#
#   type="$1"
#
#   if [ -z "$3" ]
#   then
#     path="."
#     name="$2"
#   else
#     path="$2"
#     name="$3"
#   fi
#
#   /usr/bin/find "$path" -type "$type" -name "$name"
# }
#
# function ff() {
#   shorthand-find-function "f" "$1" "$2"
# }
#
# function fd() {
#   shorthand-find-function "d" "$1" "$2"
# }
