#!/bin/sh

################################
# Ask question and expect one of the given answer
# ask_question [fd number] [question] [expected replies]
ask_question() {
  # -- Generic part --
  local REPLY
  local STDIN=/dev/fd/0
  if [ -c "/dev/fd/$1" ]; then
    STDIN=/dev/fd/$1
    shift $(min 1 $#)
  fi
  read ${1:+-p "$1"} REPLY <${STDIN}
  shift $(min 1 $#)
  # -- Custom part --
  echo "$REPLY"
  for ACK; do
    [ "$REPLY" = "$ACK" ] && return 0
  done
  return 1
}

# Get answers
question() {
    local Q="${1:?No question specified...}"
    local D="$2"
    echo -n "$Q ${D:+('$D') }: " >&2
    local A; read -r A
    [ -z "$A" ] && echo "$D" || echo "$A"
}
question2() {
    local Q="$1" D="$2"
    shift 2
    local A=""
    while ! is_in "$A" "$@" ; do
        A="$(question "$Q" "$D")"
    done
    echo "$A"
}
question_v() {
    local _V="${1:?No variable specified...}"
    shift; local A="$(question "$@")"
    shift; [ -z "$A" ] && eval $_V="$@" || eval $_V="$A"
}
question2_v() {
    local _V="${1:?No variable specified...}"
    local Q="$2" D="$3"
    shift 3
    eval $_V="$(question2 "$Q" "$D" "$@")"
}
confirmation() {
    local V
    question_v V "$1 (y/n)"
    [ "$V" = "y" ] || [ "$V" = "Y" ] 
}

# Ask for a file
# ask_file [fd number] [question] [file test] [default value]
ask_file() {
  # -- Generic part --
  local REPLY
  local STDIN=/dev/fd/0
  if [ -c "/dev/fd/$1" ]; then
    STDIN=/dev/fd/$1
    shift $(min 1 $#)
  fi
  read ${1:+-p "$1"} REPLY <${STDIN}
  shift $(min 1 $#)
  # -- Custom part --
  [ -z "$REPLY" ] && REPLY="$2"
  echo "$REPLY"
  test ${1:-e} "$REPLY"
}

# Get password
ask_passwd() {
  local PASSWD
  trap "stty echo; trap INT" INT; stty -echo
  read -p "${1:-Password: }" PASSWD; echo
  stty echo; trap - INT
  echo $PASSWD
}

################################
# Retry
alias retry='retry.sh'

# Repeat
repeat() {
  local NUM="${1:?No repeat count specified...}"
  shift
  for NUM in $(seq $NUM); do "$@"; done
}
