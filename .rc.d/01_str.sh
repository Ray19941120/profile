#!/bin/sh

# Return a string with uniq words
alias str_uniqw='str_uniq " " " "'
str_uniq() {
  local _IFS="${1:- }"
  local _OFS="${2}"
  shift 2
  #printf -- '%s\n' $@ | sort -u | xargs
  #printf -- "$@"
  printf '%s' "$@" | awk -vRS="$_IFS" -vORS="$_OFS" '!seen[$0]++ {str=str$1ORS} END{sub(ORS"$", "", str); printf "%s\n",str}'
}

# To lower
alias toLower='str_lower'
str_lower() {
  echo "${@}" | tr "[:upper:]" "[:lower:]"
}

# To upper
alias toUpper='str_upper'
str_upper() {
  echo "${@}" | tr "[:lower:]" "[:upper:]"
}