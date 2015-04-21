#!/bin/sh

################################
# To lower
toLower() {
  echo "${@}" | tr "[:upper:]" "[:lower:]"
}

# To upper
toUpper() {
  echo "${@}" | tr "[:lower:]" "[:upper:]"
}

################################
# Ask question and expect one of the given answer
# ask_question [fd number] [question] [expected replies]
ask_question() {
  local REPLY
  local STDIN=/dev/fd/0
  if isint "$1"; then
    STDIN=/dev/fd/$1
    shift $(min 1 $#)
  fi
  read ${1:+-p "$1"} REPLY <${STDIN}
  echo "$REPLY"
  shift $(min 1 $#)
  for ACK; do
    [ "$REPLY" = "$ACK" ] && return 0
  done
  return 1
}

# Ask for a file
# ask_file [fd number] [question] [file test] [default value]
ask_file() {
  local REPLY
  local STDIN=/dev/fd/0
  if isint "$1"; then
    STDIN=/dev/fd/$1
    shift $(min 1 $#)
  fi
  read ${1:+-p "$1"} REPLY <${STDIN}
  shift $(min 1 $#)
  [ -z "$REPLY" ] && REPLY="$2"
  echo "$REPLY"
  test ${1:-e} "$REPLY"
}

# Get password
ask_passwd() {
  local PASSWD
  trap "stty echo; trap SIGINT" SIGINT; stty -echo
  read -p "${1:-Password: }" PASSWD; echo
  stty echo; trap SIGINT
  echo $PASSWD
}

################################
# Create file backup
mkbak() {
  cp "${1:?Please specify input file 1}" "${1}.$(date +%Y%m%d-%H%M%S).bak"
}

# Strip ANSI codes
alias rm-ansi='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'

################################
# Hex to signed 32
hex2int32() {
  local MAX=$((1<<${2:-32}))
  local MEAN=$(($(($MAX>>1))-1))
  local RES=$(printf "%d" "$1")
  [ $RES -gt $MEAN ] && RES=$((RES-MAX))
  echo $RES
}

# Hex to signed 64
hex2int64() {
  local MAX=$((1<<${2:-64}))
  local MEAN=$(($(($MAX>>1))-1))
  local RES=$(printf "%d" "$1")
  [ $RES -gt $MEAN ] && RES=$((RES-MAX))
  echo $RES
}

# Hex to unsigned 64
hex2uint32() {
  printf "%d" "$1"
}

# Hex to unsigned 64
uint2hex() {
  printf "0x%x" "$1"
}

################################
# Convert to libreoffice formats
conv_soffice() {
  local FORMAT="${1:?No output format specified}"
  shift $(min 1 $#)
  unoconv -f "$FORMAT" "$@" ||
    soffice --headless --convert-to "$FORMAT" "$@"
}

# Convert to PDF
conv_pdf() {
  # sudo apt-get install wv texlive-base texlive-latex-base ghostscript
  for FILE in "$@"; do
    wvPDF "$FILE" "${FILE%.*}.pdf"
  done
}

# Merge PDFs
merge_pdf() {
  local INPUT="$(shell_rtrim 1 "$@")"; shift $(($#-1))
  eval command -p gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="$@" "$INPUT"
}
