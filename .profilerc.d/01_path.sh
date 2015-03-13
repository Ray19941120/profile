#!/bin/sh

# Prepend to path
path_prepend() {
  local DIR
  for DIR; do
    #if ! [[ "$PATH" =~ "${DIR}" ]] && [[ -d "$DIR" ]]; then
    if [ -d "$DIR" ] && ! (echo "$PATH" | grep "${DIR}" >/dev/null); then
      export PATH="${DIR}${PATH:+:$PATH}"
    fi
  done
}

# Append to path
path_append() {
  local DIR
  for DIR; do
    #if ! [[ "$PATH" =~ "${DIR}" ]] && [[ -d "$DIR" ]]; then
    if [ -d "$DIR" ] && ! (echo "$PATH" | grep "${DIR}" >/dev/null); then
      export PATH="${PATH:+$PATH:}${DIR}"
    fi
  done
}

# Cleanup path
path_cleanup() {
  #export PATH="${PATH//\~/${HOME}}"
  #export PATH="${PATH//.:/}"
  export PATH="$(echo "$PATH" | sed -e 's|~|'"${HOME}"'|g' -e 's|\.\:||g')"
}

# Main
unalias path_append 2>/dev/null
eval path_append /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
unalias path_prepend 2>/dev/null
eval path_prepend "$HOME/bin" "$HOME/bin/profile"
