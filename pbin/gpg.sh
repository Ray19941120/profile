#!/bin/sh
#
# Filename: gpg.sh
# Initial date: 2012/11/31
# Licence: GNU GPL
# Dependency: gpg
# optional: zenity, wipe
# Author: Oliv5 <oliv5@caramail.com>

# Variables
VERSION=0.99
PASSPHRASE=""
RECIPIENT=""
NB_ENCRYPT=0
NB_DECRYPT=0

# Options
EN_ENCRYPT=1
EN_DECRYPT=1
EN_AUTODETECT=1
EN_SIGN=""
DELETE=1
SIMULATE=""
OVERWRITE=""
VERBOSE="false"
STDOUT="/dev/null"

# Autodetect zenity & display
ZENITY=""
xhost +si:localuser:$(whoami) >/dev/null 2>&1 && {
  which zenity >/dev/null && ZENITY=1
}

# Get command line options
while getopts egdk:fsovz OPTNAME
do case "$OPTNAME" in
  e)  EN_DECRYPT="";EN_AUTODETECT="";;
  d)  EN_ENCRYPT="";EN_AUTODETECT="";;
  g)  EN_SIGN=1;;
  k)  RECIPIENT="$OPTARG";;
  f)  DELETE=""; echo "Keeping input files." >"$STDOUT";;
  s)  SIMULATE="true"; echo "Performing a dry-run with no file changed." >"$STDOUT";;
  o)  OVERWRITE="--yes";;
  v)  VERBOSE=""; STDOUT="/dev/stdout";;
  z)  ZENITY="";;
  [?]) echo >&2 "Usage: $(basename $0) v$VERSION [-e] [-g] [-d] [-k key] [-f] [-s] [-v] [-z]  ... directories/files"
       echo >&2 "-e    encrypt only"
       echo >&2 "-g    sign (with -e only)"
       echo >&2 "-d    decrypt only"
       echo >&2 "-k    select recipent key"
       echo >&2 "-f    do not delete input files"
       echo >&2 "-s    simulate"
       echo >&2 "-o    overwrite output file"
       echo >&2 "-v    verbose"
       echo >&2 "-z    no zenity"
       exit 1;;
  esac
done
shift $(expr $OPTIND - 1)

# Display a piece of information
DisplayInfo() {
  if [ -z "$ZENITY" ]; then
    echo "$1"
    echo "$2"
  else
    zenity --info --title "$1" --text "$2" --timeout 10
  fi
}

# Display a warning
DisplayWarning() {
  if [ -z "$ZENITY" ]; then
    echo "$1"
    echo "$2"
  else
    zenity --warning --title "$1" --text "$2" --timeout 10
  fi
}

# Display a question
DisplayQuestion() {
  if [ -z "$ZENITY" ]; then
    IFS="$(printf '\n')"
    #read -s -t 30 -p "$2 " ANSWER
    read -p "$2 " ANSWER </dev/tty
    echo $ANSWER
  else
    echo $(zenity --title "$1" --entry --hide-text --text="$2" --timeout 30 | sed 's/^[ \t]*//;s/[ \t]*$//')
  fi
}

# Display a list of choices, get selection
DisplayList() {
  local TITLE="$1"
  local DESCR="$2"
  local HEADER1="$3"
  local HEADER2="$4"
  shift 4
  if [ -z "$ZENITY" ]; then
    echo "$TITLE" >/dev/stderr
    echo "$@" >/dev/stderr
    #read -t 30 -p "$DESCR " ANSWER
    read -p "$DESCR " ANSWER </dev/tty
    echo $ANSWER
  else
    zenity --list --radiolist --timeout 30 --title "$TITLE" --text "$DESCR" --column "$HEADER1" --column "$HEADER2" "$@"
  fi
}

getRecipient() {
    local IFS=":"
    set -- $(gpg --list-keys --with-colons | awk -F: 'BEGIN{num=0} /pub/{num++;printf "%s:%s:",(num==1)?"TRUE":"",$10}')
    DisplayList "Encryption Keys" "Select the encryption key:" "*" "Available keys:" "$@"
}

deleteFiles() {
  for FILES; do
    $VERBOSE echo "Delete input file '$FILE'"
    if command -v wipe >/dev/null && [ ! -L "$FILE" ] && [ $(stat -c %s "$FILE") -lt 25000000 ]; then
      $SIMULATE wipe -D -q -f "$FILE"
    else
      $SIMULATE rm -v "$FILE"
    fi
  done
}

# Decrypt file
decrypt(){
  local INPUT="$1"
  local OUTPUT="${INPUT%.*}"
  if [ "$OUTPUT" = "$INPUT" ]; then
    OUTPUT="${OUTPUT}.out"
  fi
  echo "Decrypting file '$INPUT' into '$OUTPUT'"

  # Collect GnuPG passphrase
  if [ -z "$PASSPHRASE" ]; then
    PASSPHRASE="$(DisplayQuestion "Decryption" "Enter your key GnuPG passphrase:")"
    if [ -z "$PASSPHRASE" ]; then
      $VERBOSE DisplayWarning "No passphrase" "Decryption is disabled!"
      unset EN_DECRYPT
      continue
    fi
  fi

  # Decrypt
  echo "$PASSPHRASE" | $SIMULATE gpg -v --batch $OVERWRITE --passphrase-fd 0 -o "$OUTPUT" -d "$INPUT"

  # One more file!
  if [ -f "$OUTPUT" ]; then
    NB_DECRYPT=$(($NB_DECRYPT+1))
  fi

  # Delete original file if new one is present
  if [ ! -z "$DELETE" -a -f "$OUTPUT" ]; then
    deleteFiles "$INPUT"
  fi
}

#Encrypt file
encrypt() {
  local INPUT="$1"
  local OUTPUT="${INPUT}.gpg"
  echo "Encrypting file '$INPUT' into '$OUTPUT'"

  if [ -z "$RECIPIENT" ]; then
    # List the available keys
    KEYS="$(gpg --list-keys --with-colons | awk -F: '/pub/ {print $10}')"

    # Select the key
    RECIPIENT="$(getRecipient)"
    if [ -z "$RECIPIENT" ]; then
      $VERBOSE DisplayWarning "No key" "Encryption is disabled!"
      unset EN_ENCRYPT
      continue
    fi
  fi

  if [ -z "$PASSPHRASE" ]; then
    if [ ! -z "$EN_SIGN" ]; then
      PASSPHRASE="$(DisplayQuestion "Signature" "Enter your key GnuPG passphrase:")"
      if [ -z "$PASSPHRASE" ]; then
        $VERBOSE DisplayWarning "No passphrase" "Signing is disabled!"
        unset EN_SIGN
      fi
    fi
  fi

  $VERBOSE echo "Recipient $RECIPIENT"

  # Encrypt
  if [ ! -z "$EN_SIGN" ]; then
    echo "$PASSPHRASE" | $SIMULATE gpg -v --batch $OVERWRITE --no-default-recipient --recipient "$RECIPIENT" --trust-model always --encrypt --sign -o "$OUTPUT" "$INPUT"
  else
    $SIMULATE gpg -v --batch $OVERWRITE --no-default-recipient --recipient "$RECIPIENT" --trust-model always --encrypt -o "$OUTPUT" "$INPUT"
  fi

  # One more file!
  if [ -f "$OUTPUT" ]; then
    NB_ENCRYPT=$(($NB_ENCRYPT+1))
  fi

  # Delete original file if new one is present
  if [ ! -z "$DELETE" -a -f "$OUTPUT" ]; then
    deleteFiles "$INPUT"
  fi
}

# Main
true ${@:?No file/directory specified...}
# Loop through nautilus files or command line files
#printf %s "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-"${@:-.}"}" | while read -r SRC; do
IFS="$(printf '\n')"
LIST="$(printf %s "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-"$@"}" | sed -e 's/\n$//')"
for SRC in "$LIST"; do
  for FILE in $(find "$SRC" ! -type d); do
    if [ -n "$EN_AUTODETECT" ]; then
      if echo "$FILE" | grep -E "\.(gpg|pgp)$" >/dev/null; then
        if [ -n "$EN_DECRYPT" ]; then
          decrypt "$FILE" >"$STDOUT" 2>&1
        fi
      else
        if [ -n "$EN_ENCRYPT" ]; then
          encrypt "$FILE" >"$STDOUT" 2>&1
        fi
      fi
    else
      if [ -n "$EN_DECRYPT" ]; then
        decrypt "$FILE" >"$STDOUT" 2>&1
      elif [ -n "$EN_ENCRYPT" ]; then
        encrypt "$FILE" >"$STDOUT" 2>&1
      fi
    fi
  done
done

# Exit status
$VERBOSE DisplayInfo "Job complete!" "Encrypted files: $NB_ENCRYPT\nDecrypted files: $NB_DECRYPT"
exit 0
