#! /bin/bash

function update_title () {
  local a
  # escape '%' in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}
  print -nz "%20>...>$a"
  read -rz a

  print -n "\e]0;${(%)a}:${(%)2}\a"
}

# called just before the prompt is printed
function _zsh_title__precmd() {
  update_title "zsh" "%20<...<%~"
}

# called just before a command is executed
function _zsh_title__preexec() {
  local -a cmd

  # Escape '\'
  1=${1//\\/\\\\\\\\}

  cmd=(${(z)1})             # Re-parse the command line

  # Construct a command that will output the desired job number.
  case $cmd[1] in
    fg) cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
    %*) cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
  esac
  update_title "$cmd" "%20<...<%~"
}

precmd_functions+=(_zsh_title__precmd)
preexec_functions+=(_zsh_title__preexec)
