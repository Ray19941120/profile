#!/bin/sh

# Find files implementations
_ffind1() {
  local FCASE="${FCASE:--}name"
  local FILES="${1##*/}"
  local DIR="${1%"$FILES"}"
  shift 2>/dev/null
  local REGEX='s/;!/" -o -not '${FCASE}' "/g ; s/&!/" -a -not '${FCASE}' "/g ; s/;/" -o '${FCASE}' "/g ; s/&/" -a '${FCASE}' /g'
  ( set -f; FILES="\"$(echo $FILES | sed -e "$REGEX")\""
    eval find "${DIR:-.}" -nowarn ${FTYPE:+-type $FTYPE} ${FXTYPE:+-xtype $FXTYPE} \\\( ${FILES:+$FCASE "$FILES"} -true \\\) ${FARGS} "$@")
}
_ffind2() {
  local FCASE="${FCASE:--}regex"
  local FILES="${1##*/}"
  local DIR="${1%"$FILES"}"
  shift 2>/dev/null
  ( set -f; FILES="$(echo $FILES | sed -e 's/;/|/g ; s/\./\\./g ; s/*/.*/g')"
    find "${DIR:-.}" -regextype posix-extended -nowarn ${FTYPE:+-type $FTYPE} ${FXTYPE:+-xtype $FXTYPE} ${FILES:+$FCASE ".*/($FILES)"} ${FARGS} "$@")
}
alias _ffind='_ffind2'
alias     ff='FCASE=   FTYPE=  FXTYPE=  FARGS= _ffind'
alias    fff='FCASE=   FTYPE=f FXTYPE=  FARGS= _ffind'
alias    ffd='FCASE=   FTYPE=d FXTYPE=  FARGS= _ffind'
alias    ffl='FCASE=   FTYPE=l FXTYPE=  FARGS= _ffind'
alias   ffll='FCASE=   FTYPE=l FXTYPE=f FARGS= _ffind'
alias   fflb='FCASE=   FTYPE=l FXTYPE=l FARGS= _ffind'
alias    iff='FCASE=-i FTYPE=  FXTYPE=  FARGS= _ffind'
alias   ifff='FCASE=-i FTYPE=f FXTYPE=  FARGS= _ffind'
alias   iffd='FCASE=-i FTYPE=d FXTYPE=  FARGS= _ffind'
alias   iffl='FCASE=-i FTYPE=l FXTYPE=  FARGS= _ffind'
alias  iffll='FCASE=-i FTYPE=l FXTYPE=f FARGS= _ffind'
alias  ifflb='FCASE=-i FTYPE=l FXTYPE=l FARGS= _ffind'
alias    ff0='FCASE=   FTYPE=  FXTYPE=  FARGS=-print0 _ffind'
alias   fff0='FCASE=   FTYPE=f FXTYPE=  FARGS=-print0 _ffind'
alias   ffd0='FCASE=   FTYPE=d FXTYPE=  FARGS=-print0 _ffind'
alias   ffl0='FCASE=   FTYPE=l FXTYPE=  FARGS=-print0 _ffind'
alias  ffll0='FCASE=   FTYPE=l FXTYPE=f FARGS=-print0 _ffind'
alias  fflb0='FCASE=   FTYPE=l FXTYPE=l FARGS=-print0 _ffind'
alias   iff0='FCASE=-i FTYPE=  FXTYPE=  FARGS=-print0 _ffind'
alias  ifff0='FCASE=-i FTYPE=f FXTYPE=  FARGS=-print0 _ffind'
alias  iffd0='FCASE=-i FTYPE=d FXTYPE=  FARGS=-print0 _ffind'
alias  iffl0='FCASE=-i FTYPE=l FXTYPE=  FARGS=-print0 _ffind'
alias iffll0='FCASE=-i FTYPE=l FXTYPE=f FARGS=-print0 _ffind'
alias ifflb0='FCASE=-i FTYPE=l FXTYPE=l FARGS=-print0 _ffind'
alias    ffs='ff    2>/dev/null'
alias   fffs='fff   2>/dev/null'
alias   ffds='ffd   2>/dev/null'
alias   ffls='ffl   2>/dev/null'
alias  fflls='ffll  2>/dev/null'
alias  fflbs='fflb  2>/dev/null'
alias   iffs='iff   2>/dev/null'
alias  ifffs='ifff  2>/dev/null'
alias  iffds='iffd  2>/dev/null'
alias  iffls='iffl  2>/dev/null'
alias ifflls='iffll 2>/dev/null'
alias ifflbs='ifflb 2>/dev/null'

# Backward find
_bfind1() {
  local ABSPATH="$(readlink -f "${1:-$PWD}")"
  local FILES="${ABSPATH##*/}"
  local DIR="${ABSPATH%$FILES}"
  DIR="${DIR:-.}"
  local FIRSTMATCH="$2"
  local FOUND=""
  while true; do
    #if eval test ${BTYPE:--e} "\"$DIR/$FILES\""; then 
    if test ${BTYPE:--e} "$DIR/$FILES"; then 
      FOUND="$DIR"
      [ ! -z "$FIRSTMATCH" ] && break
    fi
    [ -z "$DIR" -o "$DIR" == "." ] && break
    DIR="${DIR%/*}"
  done
  echo "$FOUND"
}
alias _bfind='_bfind1'
alias  bf='BTYPE=   _bfind'
alias bff='BTYPE=-f _bfind'
alias bfd='BTYPE=-d _bfind'

# Find breadth-first (width-first)
_wfind1() { _ffind "${@:-*}" -prune -printf '%d\t%p\n' | sort -nk1 | cut -f2-; }
alias _wfind='_wfind1'
alias   wf='FCASE= FTYPE=  FXTYPE=  FARGS= _wfind'
alias  wff='FCASE= FTYPE=f FXTYPE=  FARGS= _wfind'
alias  wfd='FCASE= FTYPE=d FXTYPE=  FARGS= _wfind'
alias  wfl='FCASE= FTYPE=l FXTYPE=  FARGS= _wfind'
alias wfll='FCASE= FTYPE=l FXTYPE=f FARGS= _wfind'
alias wflb='FCASE= FTYPE=l FXTYPE=l FARGS= _wfind'

# File grep implementations
_fgrep1() {
  if [ $# -gt 1 ]; then
    local ARGS="$(arg_rtrim 1 "$@")"; shift $(($#-1))
  else
    local ARGS="$1"; shift $#
  fi
  (set -f; _ffind1 "${@:-}" -type f -print0 | eval xargs -0 grep -nH --color ${GCASE} ${GARGS} -e "${ARGS:-''}")
}
_fgrep2() {
  if [ $# -gt 1 ]; then
    local ARGS="$(arg_rtrim 1 "$@")"; shift $(($#-1))
  else
    local ARGS="$1"; shift $#
  fi
  local FILES="${1##*/}"
  local DIR="${1%"$FILES"}"
  FILES="$(echo "${FILES}" | sed -e 's/;/ --include=/g')"
  (set -f; eval grep -RnH --color ${GCASE} ${GARGS} -e "$ARGS" ${FILES:+--include="$FILES"} "${DIR:-.}")
}
alias _fgrep='_fgrep2'
alias    gg='FCASE= FTYPE=  FXTYPE=  FARGS= GCASE=   GARGS=   _fgrep'
alias   igg='FCASE= FTYPE=  FXTYPE=  FARGS= GCASE=-i GARGS=   _fgrep'
alias   ggl='FCASE= FTYPE=  FXTYPE=  FARGS= GCASE=   GARGS=-l _fgrep'
alias  iggl='FCASE= FTYPE=  FXTYPE=  FARGS= GCASE=-i GARGS=-l _fgrep'
alias   ggs='gg   2>/dev/null'
alias  iggs='igg  2>/dev/null'
alias  ggls='ggl  2>/dev/null'
alias iggls='iggl 2>/dev/null'
#ggl() {  gg "$@" | cut -d : -f 1 | uniq; }
#iggl(){ igg "$@" | cut -d : -f 1 | uniq; }

# Search & replace
_fsed1() {
  # Get arguments
  local SEDOPT="$(arg_rtrim 3 "$@")"; shift $(($#-3))
  local IN="$1"; local OUT="$2"; local FILES="$3"
  echo "Preparing to replace '$IN' by '$OUT' in files '$FILES' ${SEDOPT:+with options '$SEDOPT'}"
  # Ask for options
  local _SHOW; read -p "Show each line changed ? (Y/n) " _SHOW
  local _BACKUP; read -p "Backup each file ? (Y/n) " _BACKUP
  local _CONFIRM; read -p "Confirm each file change ? (Y/n) " _CONFIRM
  # Manage options
  [ "$_SHOW" != "n" -a "$_SHOW" != "N" ] && _SHOW=1 || unset _SHOW
  [ "$_CONFIRM" != "n" -a "$_CONFIRM" != "N" ] && _CONFIRM=1 || unset _CONFIRM
  [ "$_BACKUP" != "n" -a "$_BACKUP" != "N" ] && _BACKUP=".$(date +%Y%m%d-%H%M%S).bak" || unset _BACKUP
  # Call find and sed
  _ffind "$FILES" $SEXCLUDE -type f \
    ${_CONFIRM:+-exec sh -c 'read -p "Processing file {} ? (enter/ctrl-c)" DUMMY' \;} \
    ${_BACKUP:+-execdir sh -c "grep '$IN' '{}' >/dev/null" \;} \
    -execdir sed $SEDOPT --in-place${_BACKUP:+=$_BACKUP} ${_SHOW:+-e "\|$IN|{w /dev/stderr" -e "}"} -e "s|$IN|$OUT|g" "{}" \;
}
alias _fsed='_fsed1'
alias  hh='FCASE=   FTYPE=  FXTYPE= FARGS= SEXCLUDE= _fsed'
alias ihh='FCASE=-i FTYPE=  FXTYPE= FARGS= SEXCLUDE= _fsed'
