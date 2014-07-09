#!/bin/bash

# Set load flag
export ENV_CNT=$(expr ${ENV_CNT:-0} + 1)
export ENV_PROFILE_D=$ENV_CNT

#alias
alias end='return 0 2>/dev/null || exit 0'

# Add to path function
function path-add() {
  for DIR in "$@"; do
    if ! [[ $PATH =~ $DIR ]]; then
      export PATH="$PATH:$DIR"
    fi
  done
}

# Call stack
function print-callstack() {
  # skipping i=0 as this is print_call_trace itself
  for ((i = 1; i < ${#FUNCNAME[@]}; i++)); do
    echo -n  ${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]}:${FUNCNAME[$i]}"(): "
    sed -n "${BASH_LINENO[$i-1]}p" $0
  done
}

# Set error handler
function trap-map() {
  trap 'die "Error handler:" -1 ${LINENO}' ${@:-1 15} ERR
}

# Die function
function die () {
  printf '%s%s\n' "${3:+(line $3) }" "${1:-Unknown error. abort...}"
  [[ $- == *i* ]] && return ${2:--1} || exit ${2:--1}
}

# List user functions
function fct-ls() {
  declare -F | cut -d" " -f3 | egrep -v "^_"
}

# Export user functions from script
function fct-export() {
  export -f "$@"
}

# Export all user functions
function fct-export-all() {
  export -f $(fct-ls)
}

# Get script directory
function pwd-get() {
  echo $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
}

# Function exist test
function cmd-exists() {
  command -v ${1} >/dev/null
}
