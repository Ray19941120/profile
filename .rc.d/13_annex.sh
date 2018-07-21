#!/bin/sh

# Annex aliases
alias gana='git annex add'
alias gant='git annex status'
alias ganst='git annex status'
alias ganl='git annex list'
alias ganls='git annex list'
alias ganlc='git annex find | wc -l'
alias ganf='git annex find'
alias ganfc='git annex find | wc -l'
alias gans='git annex sync'
alias gansn='git annex sync --no-commit'
alias gansp='git annex sync --no-commit --no-push'
alias gansu='git annex sync --no-commit --no-pull'
alias gansc='git annex sync --content'
alias ganscf='git annex sync --content --fast'
alias gang='git annex get'
alias ganc='git annex copy'
alias ganca='git annex copy --all'
alias gancf='git annex copy --fast'
alias ganct='git annex copy --to'
alias gancat='git annex copy --all --to'
alias gancft='git annex copy --fast --to'
alias gancf='git annex copy --from'
alias gancaf='git annex copy --all --from'
alias gancff='git annex copy --fast --from'
alias gand='git annex drop'
alias gandd='git annex forget --drop-dead'
alias gani='git annex info'
alias gan='git annex'
alias annex='git annex'

########################################
# Check annex exists
annex_exists() {
  git ${1:+--git-dir="$1"} config --get annex.version >/dev/null 2>&1
}

# Check annex has been modified
annex_modified() {
  test ! -z "$(git ${1:+--git-dir="$1"} annex status)"
}

# Test annex direct-mode
annex_direct() {
  [ "$(git ${1:+--git-dir="$1"} config --get annex.direct)" = "true" ]
}

# Test annex bare
annex_bare() {
  annex_exists "$@" && ! annex_direct "$@" && git_bare "$@"
}

# Test annex standard (indirect, not bare)
annex_std() {
  annex_exists "$@" && ! annex_direct "$@" && ! git_bare "$@"
}

# Init annex
annex_init() {
  git init "$1" && git annex init "${2:-$(uname -n)}"
}

# Init annex bare repo
annex_init_bare() {
  git init --bare "$1" && git annex init "${2:-$(uname -n)}"
}

# Uninit annex
annex_uninit() {
  git annex uninit && git config --replace-all core.bare false
}

# Init annex in direct mode
annex_init_direct() {
  annex_init && git annex direct
}

########################################
# Init hubic annex
annex_init_hubic() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=hubic hubic_container=annex hubic_path="$REMOTEPATH" embedcreds=no ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=external externaltype=hubic hubic_container=annex hubic_path="$REMOTEPATH" embedcreds=no ${KEYID:+keyid="$KEYID"}
}

# Init gdrive annex
annex_init_gdrive() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=googledrive folder="$REMOTEPATH" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=external externaltype=googledrive folder="$REMOTEPATH" ${KEYID:+keyid="$KEYID"}
}

# Init bup annex
annex_init_bup() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=bup buprepo="$REMOTEPATH" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=bup buprepo="$REMOTEPATH" ${KEYID:+keyid="$KEYID"}
}

# Init rsync annex
annex_init_rsync() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=rsync rsyncurl="$REMOTEPATH" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=rsync rsyncurl="$REMOTEPATH" ${KEYID:+keyid="$KEYID"}
  git config --add annex.sshcaching false
}

# Init directory annex
annex_init_directory() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=directory directory="$REMOTEPATH" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=directory directory="$REMOTEPATH" ${KEYID:+keyid="$KEYID"}
  git config --add annex.sshcaching false
}

# Init gcrypt annex
annex_init_gcrypt() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=gcrypt gitrepo="$REMOTEPATH" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=gcrypt gitrepo="$REMOTEPATH" ${KEYID:+keyid="$KEYID"}
  git config --add annex.sshcaching false
}

# Init rclone annex
annex_init_rclone() {
  local NAME="${1:?No remote name specified...}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  local CHUNKS="$5"
  local PROFILE="${6:-$NAME}"
  local MAC="${7:-HMACSHA512}"
  local LAYOUT="${8:-lower}"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=rclone target="$PROFILE" prefix="$REMOTEPATH" ${CHUNKS:+chunk=$CHUNKS} mac="${MAC}" rclone_layout="$LAYOUT" ${KEYID:+keyid="$KEYID"} ||
  git annex initremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=rclone target="$PROFILE" prefix="$REMOTEPATH" ${CHUNKS:+chunk=$CHUNKS} mac="${MAC}" rclone_layout="$LAYOUT" ${KEYID:+keyid="$KEYID"}
}

########################################
# Git status for scripts
annex_st() {
  git annex status | awk -F'#;#.' '/^[\? ]?'$1'[\? ]?/ {sub(/ /,"#;#.");print $2}'
}

# Annex diff
annex_diff() {
  if ! annex_direct; then
    git diff "$@"
  fi
}

# Get remote(s) uuid
annex_uuid() {
  for REMOTE in "${@:-.*}"; do
    git config --get-regexp remote\.${REMOTE}\.annex-uuid
  done
}

# List annexed remotes
annex_remotes() {
  git config --get-regexp "remote\..*\.annex-uuid" |
    awk -F. '{print $2}' | xargs
}

# List annexed enabled remotes
annex_enabled() {
  local EXCLUDE="$(git config --get-regexp "remote\..*\.annex-ignore" true | awk -F. '{printf $2"|"}' | sed -e "s/|$//")"
  git config --get-regexp "remote\..*\.annex-uuid" |
    grep -vE "${EXCLUDE:-$^}" | 
    awk -F. '{print $2}' | xargs
}

########################################
# Assistant
alias annex_webapp='git annex webapp'
alias annex_assistant='git annex assistant'
alias annex_assistant_auto='git annex assistant --autostart'
alias annex_assistant_stop='git annex assistant --stop; git annex assistant --autostop'

########################################
# Print annex infos (inc. encryption ciphers)
annex_getinfo() {
  git annex info .
  git show git-annex:remote.log
  for REMOTE in ${@:-$(git_remotes)}; do
    echo '-------------------------'
    git annex info "$REMOTE"
  done
}

# Lookup special remote keys
annex_lookup_remote() {
  # Preamble
  git_exists || return 1
  annex_std || return 2
  # Decrypt cipher
  decrypt_cipher() {
    cipher="$1"
    echo "$(echo -n "$cipher" | base64 -d | gpg --decrypt --quiet)"
  }
  # Encrypt git-annex key
  encrypt_key() {
      local key="$1"
      local cipher="$2"
      local mac="$3"
      local enckey="$key"
      if [ -n "$cipher" ]; then
        enckey="GPG$mac--$(echo -n "$key" | openssl dgst -${mac#HMAC} -hmac "$cipher" | sed 's/(stdin)= //')"
      fi
      local checksum="$(echo -n $enckey | md5sum)"
      echo "${checksum:0:3}/${checksum:3:3}/$enckey"
  }
  # Find the special remote key from the local key
  lookup_key() {
      local encryption="$1"
      local cipher="$2"
      local mac="$3"
      local remote_uuid="$4"
      local file="$(readlink -m "$5")"
      # No file
      if [ -z "$file" ]; then
        echo >&2 "File '$5' does not exist..."
        exit 1
      fi
      # Analyse keys
      local annex_key="$(basename "$file")"
      local checksum="$(echo -n "$annex_key" | md5sum)"
      local branchdir="${checksum:0:3}/${checksum:3:3}"
      if [[ "$(git config annex.tune.branchhash1)" = true ]]; then
          branchdir="${branchdir%%/*}"
      fi
      local chunklog="$(git show "git-annex:$branchdir/$annex_key.log.cnk" 2>/dev/null | grep $remote_uuid: | grep -v ' 0$')"
      local chunklog_lc="$(echo "$chunklog" | wc -l)"
      local chunksize numchunks chunk_key line n
      # Decrypt cipher
      if [ "$encryption" = "hybrid" ] || [ "$encryption" = "pubkey" ]; then
          cipher="$(decrypt_cipher "$cipher")"
      fi
      # Pull out MAC cipher from beginning of cipher
      if [ "$encryption" = "hybrid" ] ; then
          cipher="$(echo -n "$cipher" | head  -c 256 )"
      elif [ "$encryption" = "shared" ] ; then
          cipher="$(echo -n "$cipher" | base64 -d | tr -d '\n' | head  -c 256 )"
      elif [ "$encryption" = "pubkey" ] ; then
          # pubkey cipher includes a trailing newline which was stripped in
          # decrypt_cipher process substitution step above
          IFS= read -rd '' cipher < <( printf "$cipher\n" )
      elif [ "$encryption" = "sharedpubkey" ] ; then
          # Full cipher is base64 decoded. Add a trailing \n lost by the shell somewhere
          cipher="$(echo -n "$cipher" | base64 -d)
"
      fi
      if [[ -z $chunklog ]]; then
          echo "# non-chunked" >&2
          encrypt_key "$annex_key" "$cipher" "$mac"
      elif [ "$chunklog_lc" -ge 1 ]; then
          if [ "$chunklog_lc" -ge 2 ]; then
              echo "INFO: the remote seems to have multiple sets of chunks" >&2
          fi
          while read -r line; do
              chunksize="$(echo -n "${line#*:}" | cut -d ' ' -f 1)"
              numchunks="$(echo -n "${line#*:}" | cut -d ' ' -f 2)"
              echo "# $numchunks chunks of $chunksize bytes" >&2
              for n in $(seq 1 $numchunks); do
                  chunk_key="${annex_key/--/-S$chunksize-C$n--}"
                  encrypt_key "$chunk_key" "$cipher" "$mac"
              done
          done <<<"$chunklog"
      fi
  }
  # Main variables
  local REMOTE="${1:?No remote specified...}"
  local REMOTE_CONFIG="$(git show git-annex:remote.log | grep 'name='"$REMOTE " | head -n 1)"
  local ENCRYPTION="$(echo "$REMOTE_CONFIG" | grep -oP 'encryption\=.*? ' | tr -d ' \n' | sed 's/encryption=//')"
  local CIPHER="$(echo "$REMOTE_CONFIG" | grep -oP 'cipher\=.*? ' | tr -d ' \n' | sed 's/cipher=//')"
  local UUID="$(echo "$REMOTE_CONFIG" | cut -d ' ' -f 1)"
  local MAC="$(echo "$REMOTE_CONFIG" | grep -oP 'mac\=.*? ' | tr -d ' \n' | sed 's/mac=//')"
  [ -z "$REMOTE_CONFIG" ] && { echo >&2 "Remote '$REMOTE' config not found..."; return 3; }
  [ -z "$ENCRYPTION" ] && { echo >&2 "Remote '$REMOTE' encryption not found..."; return 3; }
  [ -z "$CIPHER" -a "$ENCRYPTION" != "none" ] && { echo >&2 "Remote '$REMOTE' cipher not found..."; return 3; }
  [ -z "$UUID" ] && { echo >&2 "Remote '$REMOTE' uuid not found..."; return 3; }
  [ -z "$MAC" ] && MAC=HMACSHA1
  shift 1
  # Main processing
  git annex find --include '*' "$@" --format='${hashdirmixed}${key}/${key} ${hashdirlower}${key}/${key} ${file}\n' | while IFS=' ' read -r KEY1 KEY2 FILE; do
    echo "$REMOTE"
    echo "$FILE"
    echo "$KEY1"
    echo "$KEY2"
    lookup_key "$ENCRYPTION" "$CIPHER" "$MAC" "$UUID" "$FILE"
    echo
  done
}

# Lookup special remotes keys
annex_lookup_remotes() {
  local REMOTES="${@:-$(git_remotes)}"
  for REMOTE in $REMOTES; do
    annex_lookup_remote "$REMOTE" 2>&1
  done
}

########################################
# List annex content in an archive
_annex_archive() {
  ( set +e; # Need to go on on error
  git_exists || return 1
  if ! annex_std; then
    echo "Repository '$(git_dir)' cannot be enumerated."
    echo "Abort..."
    exit 1
  fi
  local NAME="${1:-archive}"
  local DIR="${2:-$(git_dir)/${NAME%%.*}}"
  mkdir -p "$DIR"
  if [ ! -d "$DIR" ]; then
    echo "Output directory '$DIR' cannot be created."
    echo "Abort..."
    exit 1
  fi
  local OUT="$DIR/${3:-$(git_name "annex.${NAME%%.*}").${NAME#*.}}"
  local GPG_RECIPIENT="$4"
  local GPG_TRUST="${5:+--trust-model always}"
  shift 5
  echo "Generate $OUT"
  eval "$@"
  if [ ! -r "${OUT}" ]; then
    echo "Output file is missing or empty."
    echo "Abort..."
    exit 1
  fi
  if [ ! -z "$GPG_RECIPIENT" ]; then
    gpg -v --output "${OUT}.gpg" --encrypt --recipient "$GPG_RECIPIENT" $GPG_TRUST "${OUT}" &&
      (shred -fu "${OUT}" || wipe -f -- "${OUT}" || rm -- "${OUT}")
  fi
  ls -l "${OUT}"*
  )
}

# Annex bundle
_annex_bundle() {
  local OUT="$1"
  local OWNER="${2:-$USER}"
  echo "Tar annex into $OUT"
  if annex_bare; then
    tar zcf "${OUT}" --exclude='*/creds/*' -h ./annex
  else
    git annex find | 
      awk '{print "\""$0"\""}' |
      xargs -r tar zcf "${OUT}" -h --exclude-vcs --
  fi
  [ -f "$OUT" ] && chown "$OWNER" "$OUT"
}
annex_bundle() {
  _annex_archive "bundle.tgz" "$1" "$2" "$3" "$4" "_annex_bundle \"\$OUT\" \"$5\""
}

# Annex enumeration
_annex_enum() {
  git --git-dir="$(git_dir)" annex find "$(git_root)" --include '*' --print0 | xargs -r0 -n1 sh -c '
    FILE="$1"
    printf "\"%s\" <- \"%s\"\n" "$(readlink -- "$FILE")" "$FILE" | grep -F ".git/annex"
  ' _ > "${OUT%.*}"
  gzip -S .gz -9 "${OUT%.*}"
}
annex_enum() {
  _annex_archive "enum.local.txt.gz" "$1" "$2" "$3" "$4" "_annex_enum"
}

# Store annex infos
annex_info(){
  _annex_archive "info.txt.gz" "$1" "$2" "$3" "$4" "
    annex_getinfo > \"\${OUT%.*}\"
    gzip -S .gz -9 \"\${OUT%.*}\"
"
}

# Enum special remotes
annex_enum_remotes() {
  _annex_archive "enum.remotes.txt.gz" "$1" "$2" "$3" "$4" "
    annex_lookup_remotes > \"\${OUT%.*}\"
    gzip -S .gz -9 \"\${OUT%.*}\"
"
}

########################################
# Annex download/upload
alias annex_download='git annex get'
alias annex_dl='git annex get'
alias annex_ul='annex_upload'
alias annex_send='annex_upload'
annex_upload() {
  local ARGS=""
  local PREV=""
  local TO=""
  for ARG; do
     if [ "$PREV" = "--to" ]; then
      TO="${TO:+$TO }'$ARG'"
     elif [ "$ARG" != "--to" ]; then
      ARGS="${ARGS:+$ARGS }'$ARG'"
     fi
     PREV="$ARG"
  done
  for REMOTE in ${TO:-$(annex_enabled)}; do
    eval git annex copy ${ARGS:-.} --to "$REMOTE"
  done
}

########################################
# Transfer files to the specified repos, one by one
# without downloading the whole repo locally at once
# Options make it similar to "git annex copy" and "git annex move"
# $FROM is used to selected the origin repo
# $DROP is used to drop the newly retrieved files (when not empty)
# $DBG is used to print the command on stderr (when not empty)
# $ALL is used to select all files (when not empty)
alias annex_transfer='DBG= DROP=1 _annex_transfer'
alias annex_move='DBG= DROP=2 _annex_transfer'
_annex_transfer() {
  annex_exists || return 1
  local REPOS="${1:-$(annex_enabled)}"
  local DBG="${DBG:+echo}"
  local SELECT=""
  [ $# -gt 0 ] && shift
  [ -z "$REPOS" ] && return 0
  [ -z "$ALL" ] && for REPO in $REPOS; do SELECT="${SELECT:+ $SELECT --and }--not --in $REPO"; done
  if git_bare; then
    # Bare repositories do not have "git annex find"
    echo "BARE REPOS NOT SUPPORTED YET"
  else
    # Plain git repositories
    # Get & copy local files one by one
    git annex find --include='*' $SELECT --print0 "$@" | xargs -0 -rn1 sh -c '
      DBG="$1";REPOS="$2";SRC="$3"
      if [ -L "$SRC" -a ! -e "$SRC" ]; then
        $DBG git annex get ${FROM:+--from "$FROM"} "$SRC" || exit $?
      else
        [ "$DROP" != "2" ] && unset DROP
      fi
      for REPO in $REPOS; do
        while ! $DBG git annex copy --to "$REPO" "$SRC"; do true; done
      done
      [ -n "$DROP" ] && $DBG git annex drop "$SRC"
      exit 0
    ' _ "$DBG" "$REPOS"
  fi
}

# Rsync files to the specified location, one by one
# without downloading the whole repo locally at once
# Options make it similar to "git annex copy" and "git annex move"
# $FROM is used to selected the origin repo
# $DROP is used to drop the newly retrieved files (when not empty)
# $DBG is used to print the command on stderr (when not empty)
# $DELETE is used to delete the missing existing files (1=dry-run, 2=do-it)
# $RSYNC_OPT is used to specify rsync options
alias annex_rsync='DBG= DELETE= DROP=1 SKIP= RSYNC_OPT= _annex_rsync'
alias annex_rsyncd='DBG= DELETE=2 DROP=1 SKIP= RSYNC_OPT= _annex_rsync'
alias annex_rsyncds='DBG= DELETE=1 DROP=1 SKIP= RSYNC_OPT= _annex_rsync'
_annex_rsync() {
  annex_exists || return 1
  local DST="${1:?No destination specified...}"
  local SRC="${PWD}"
  local DBG="${DBG:+echo}"
  local RSYNC_OPT="${RSYNC_OPT:--v -r -z -s -i --inplace --size-only --progress -K -L -P}"
  [ $# -gt 0 ] && shift
  [ "${SRC%/}" = "${DST%/}" ] && return 2
  [ "${DST%%:*}" = "${DST}" ] && DST="localhost:/${DST}"
  if git_bare; then
    # Bare repositories do not have "git annex find"
    echo "BARE REPOS NOT TESTED YET. Press enter to go on..." && read NOP
    find annex/objects -type f | while read SRCNAME; do
      annex_fromkey "$SRCNAME" | xargs -0 -rn1 echo | while read DSTNAME; do
        DST_DIR="$(dirname "${DST##*:}/${DSTNAME}")"
        while ! $DBG rsync --rsync-path="mkdir -p \"${DST_DIR}\" && rsync" $RSYNC_OPT "${SRC}/${SRCNAME}" "${DST}/${DSTNAME}"; do sleep 1; done
      done
    done
  else
    # Plain git repositories
    # Get & copy local files one by one
    git annex find --include='*' --print0 "$@" | xargs -0 -rn1 sh -c '
      DBG="$1";SKIP="$2";RSYNC_OPT="$3";DST="$4/$5";SRC="$5"
      DST_PROTO="${DST%%/*}"
      DST_FILE="/${DST#*/}"
      DST_DIR="$(dirname "${DST##*:}/${DSTNAME}")"
      DST_SERVER="${DST_PROTO%%:*}"
      DST_PORT="${DST_PROTO##${DST_SERVER}:}"
      if [ -n "$SKIP" ]; then
        if [ "$DST_SERVER" != "localhost" ] && ssh ${DST_PORT:+-p "$DST_PORT"} "$DST_SERVER" stat -t "$DST_FILE" \>/dev/null 2\>\&1; then
          echo "Skip existing dst file ${DST}"
          exit 1
        elif stat -t "$DST_FILE" >/dev/null 2>&1; then
          echo "Skip existing dst file ${DST}"
          exit 1
        fi
      fi
      if [ -L "$SRC" -a ! -e "$SRC" ]; then
        $DBG git annex get ${FROM:+--from "$FROM"} "$SRC" || exit $?
      else
        unset DROP
      fi
      while ! $DBG rsync --rsync-path="mkdir -p \"${DST_DIR}\" && rsync" $RSYNC_OPT "$SRC" "$DST"; do sleep 1; done
      [ -n "$DROP" ] && $DBG git annex drop "$SRC"
      exit 0
    ' _ "$DBG" "${SKIP:+1}" "$RSYNC_OPT" "$DST"
    # Delete missing destination files
    if [ "$DELETE" = 1 ]; then
      while ! $DBG rsync -rni --delete --cvs-exclude --ignore-existing --ignore-non-existing "$SRC/" "$DST/"; do sleep 1; done
    elif [ "$DELETE" = 2 ]; then
      while ! $DBG rsync -ri --delete --cvs-exclude --ignore-existing --ignore-non-existing "$SRC/" "$DST/"; do sleep 1; done
    fi
  fi
}

########################################
# Drop local files which are in the specified remote repos
alias annex_drop='git annex drop -N $(annex_enabled | wc -w)'
annex_drop_fast() {
  annex_exists || return 1
  local REPOS="${1:-$(annex_enabled)}"
  local COPIES="$(echo "$REPOS" | wc -w)"
  local LOCATION="$(echo "$REPOS" | sed -e 's/ / --and --in /g')"
  [ $# -gt 0 ] && shift
  git annex drop --in $LOCATION -N "$COPIES" "$@"
}

########################################
# Annex upkeep
annex_upkeep() {
  local DBG=""
  # Add options
  local ADD=""
  local DEL=""
  local FORCE=""
  # Sync options
  local MSG="annex_upkeep() at $(date)"
  local SYNC=""
  local NO_COMMIT="--no-commit"
  local NO_PULL="--no-pull"
  local NO_PUSH="--no-push"
  local CONTENT=""
  # Copy options
  local GET=""
  local SEND=""
  local FAST="--all"
  local REMOTES="$(annex_enabled)"
  # Misc options
  local NETWORK_DEVICE="";
  local CHARGE_LEVEL="";
  local CHARGE_STATUS="";
  # Get arguments
  OPTIND=1
  while getopts "adoscpum:gefti:v:w:zh" OPTFLAG; do
    case "$OPTFLAG" in
      # Add
      a) ADD=1;;
      d) DEL=1;;
      o) FORCE=1;;
      # Sync
      s) SYNC=1; NO_COMMIT=""; NO_PULL=""; NO_PUSH="";;
      c) SYNC=1; NO_COMMIT="";;
      p) SYNC=1; NO_PULL="";;
      u) SYNC=1; NO_PUSH="";;
      t) SYNC=1; CONTENT="--content";;
      m) MSG="${OPTARG}";;
      # UL/DL
      g) GET=1;;
      e) SEND=1;;
      r) REMOTES="${OPTARG}";;
      f) FAST="--fast";;
      # Misc
      i) NETWORK_DEVICE="${OPTARG}";;
      v) CHARGE_LEVEL="${OPTARG}";;
      w) CHARGE_STATUS="${OPTARG}";;
      z) set -vx; DBG="true";;
      *) echo >&2 "Usage: annex_upkeep [-a] [-d] [-o] [-s] [-t] [-c] [-p] [-u] [-m 'msg'] [-g] [-e] [-f] [-i itf] [-v 'var lvl'] [-w 'var status1 status2 ...'] [-z] [remote1 remote2 ...] "
         echo >&2 "-a (a)dd new files"
         echo >&2 "-d add (d)eleted files"
         echo >&2 "-o f(o)rce add/delete files"
         echo >&2 "-s (s)ync, similar to -cpu"
         echo >&2 "-t sync conten(t)"
         echo >&2 "-c (c)ommit"
         echo >&2 "-p (p)ull"
         echo >&2 "-u p(u)sh"
         echo >&2 "-m (m)essage"
         echo >&2 "-g (g)et"
         echo >&2 "-e s(e)nd to remotes"
         echo >&2 "-f (f)ast get/send"
         echo >&2 "-i check network (i)nterface connection"
         echo >&2 "-v check device charging le(v)el"
         echo >&2 "-w check device charging status"
         echo >&2 "-z simulate operations"
         return 1;;
    esac
  done
  shift "$((OPTIND-1))"
  unset OPTFLAG OPTARG
  OPTIND=1
  REMOTES="${@:-$REMOTES}"
  # Base check
  annex_exists || return 1
  # Charging status
  if [ -n "$CHARGE_STATUS" ]; then
    set -- $CHARGE_STATUS
    local DEVICE="${1:-/sys/class/power_supply/battery/status}"
    local CURRENT_STATUS="$({ cat "$DEVICE" 2>/dev/null || sudo cat "$DEVICE" 2>/dev/null; } | tr '[:upper:]' '[:lower:]')"
    shift
    local FOUND=""
    for EXPECTED_STATUS; do
      if [ "$CURRENT_STATUS" = "$EXPECTED_STATUS" ]; then 
        FOUND=1
        break
      fi
    done
    set --
    if [ -z "$FOUND" ]; then
      echo "[warning] device is not in charge. Abort..."
      return 3
    fi
  fi
  # Charging level
  if [ -n "$CHARGE_LEVEL" ]; then
    set -- $CHARGE_LEVEL
    local DEVICE="${1:-/sys/class/power_supply/battery/capacity}"
    local CURRENT_LEVEL="$({ cat "$DEVICE" 2>/dev/null || sudo cat "$DEVICE" 2>/dev/null; } | tr '[:upper:]' '[:lower:]')"
    local EXPECTED_LEVEL="${2:-75}"
    set --
    if [ "$CURRENT_LEVEL" -lt "$EXPECTED_LEVEL" 2>/dev/null ]; then
      echo "[warning] device charge level ($CURRENT_LEVEL) is lower than threshold ($EXPECTED_LEVEL). Abort..."
      return 2
    fi
  fi
  # Connected network device
  #if [ -n "$NETWORK_DEVICE" ] && ! ip addr show dev "$NETWORK_DEVICE" 2>/dev/null | grep "state UP" >/dev/null; then
  if [ -n "$NETWORK_DEVICE" ] && ! ip addr show dev "$NETWORK_DEVICE" 2>/dev/null | head -n 1 | grep "UP" >/dev/null; then
    echo "[warning] network interface '$NETWORK_DEVICE' is not connected. Disable file content transfer..."
    unset CONTENT
    unset GET
    unset SEND
  fi
  # Add
  if [ -n "$ADD" ]; then
    $DBG git annex add . ${FORCE:+--force} || return $?
  fi
  # Revert deleted files
  if [ -z "$DEL" ] && ! annex_direct; then
    gstx D | xargs -r0 $DBG git checkout || return $?
    #annex_st D | xargs -r $DBG git checkout || return $?
  fi
  # Sync
  if [ -n "$SYNC" ]; then
    $DBG git annex sync ${NO_COMMIT} ${NO_PULL} ${NO_PUSH} ${CONTENT} "${MSG:+--message="$MSG"}" $REMOTES || return $?
  fi
  # Get
  if [ -n "$GET" ]; then
      $DBG git annex get ${FAST} || return $?
  fi
  # Upload
  if [ -n "$SEND" ]; then
    for REMOTE in ${REMOTES}; do
      $DBG git annex copy --to "$REMOTE" ${FAST} || return $?
    done
  fi
  return 0
}

########################################
# Find aliases
alias annex_existing='git annex find --in'
alias annex_missing='git annex find --not --in'
alias annex_wantget='git annex find --want-get --not --in'
alias annex_wantdrop='git annex find --want-drop --in'
annex_lost() { git annex list "$@" | grep -E "^_+ "; }

# Is file in annex ?
annex_isin() {
  annex_exists || return 1
  local REPO="${1:-.}"
  shift
  [ -n "$(git annex find --in "$REPO" "$@")" ]
}

# Find annex repositories
annex_find_repo() {
	ff_git0 "${1:-.}" |
		while read -d $'\0' DIR; do
			annex_exists "$DIR" && printf "'%s'\n" "$DIR"
		done 
}

########################################
# Fsck/check all
alias annex_fsck='annex_find_repo | xargs -r -I {} -n 1 sh -c "cd \"{}/..\"; pwd; git annex fsck"'
alias annex_check='annex_find_repo | xargs -r -I {} -n 1 sh -c "cd \"{}/..\"; pwd; git annex list | grep \"^_\""'

########################################
# Rename special remotes
annex_rename_special() {
	git config remote.$1.fetch dummy
	git remote rename "$1" "$2"
	git config --unset remote.$2.fetch
	git annex initremote "$1" name="$2"
}

# Revert changes in all modes (indirect/direct)
annex_revert() {
  git annex proxy -- git revert "${1:-HEAD}"
}

# Annex info
alias annex_du='git annex info --fast'

########################################
# Find files from key
# Note key = file content, so there can be
# multiple files mapped to a single key
annex_fromkey() {
  for KEY; do
    KEY="$(basename "$KEY")"
    #git show -999999 -p --no-color --word-diff=porcelain -S "$KEY" | 
    git log -n 1 -p --no-color --word-diff=porcelain -S "$KEY" |
      awk '/^(---|\+\+\+) (a|b)/{line=$0} /'$KEY'/{printf "%s\0",substr(line,5); exit 0}' |
      # Remove leading/trailing double quotes, leading "a/", trailing spaces.
      # Escape '%'
      sed -z -e 's/\s*$//' -e 's/^"//' -e 's/"$//' -e 's/^..//' -e 's/%/\%/g' |
      # printf does evaluate octal charaters from UTF8
      xargs -r0 -n1 -I {} -- printf "{}\0"
      # Sanity extension check between key and file
      #xargs -r0 -n1 sh -c '
        #[ "${1##*.}" != "${2##*.}" ] && printf "Warning: key extension ${2##*.} mismatch %s\n" "${1##*/}" >&2
        #printf "$2\0"
      #' _ "$KEY"
  done
}

# Get key from file name
annex_getkey() {
  git annex find --include='*' "${@}" --format='${key}\000'
}
annex_gethashdir() {
  git annex find --include='*' "${@}" --format='${hashdirlower}\000'
}
annex_gethashdirmixed() {
  git annex find --include='*' "${@}" --format='${hashdirmixed}\000'
}
annex_gethashpath() {
  git annex find --include='*' "${@}" --format='${hashdirlower}${key}/${key}\000'
}
annex_gethashpathmixed() {
  git annex find --include='*' "${@}" --format='${hashdirmixed}${key}/${key}\000'
}

########################################
# List unused files matching pattern
annex_unused() {
  ! annex_bare || return 1
  local PATTERNS=""
  for ARG; do PATTERNS="${PATTERNS:+$PATTERNS }-e '$ARG'"; done
  eval annex_fromkey $(git annex unused ${FROM:+--from $FROM} | awk "/^\s+[0-9]+\s/{print \$2}") ${PATTERNS:+| grep -zF $PATTERNS} | xargs -r0 -n1
}

# Drop unused files matching pattern
annex_dropunused() {
  ! annex_bare || return 1
  local IFS="$(printf ' \t\n')"
  local PATTERNS=""
  for ARG; do PATTERNS="${PATTERNS:+$PATTERNS }-e '$ARG'"; done
  git annex unused ${FROM:+--from $FROM} | grep -E '^\s+[0-9]+\s' | 
    while IFS=' ' read -r NUM KEY; do
      eval annex_fromkey "$KEY" ${PATTERNS:+| grep -zF $PATTERNS} | xargs -r0 sh -c '
        NUM="$1";KEY="$2"; shift 2
        for FILE; do
          printf "Drop unused file %s\nFile: %s\nKey: %s\n" "$NUM" "$FILE" "$KEY"
        done
        git annex dropunused "$NUM" ${FROM:+--from $FROM} ${FORCE:+--force}
        echo ""
      ' _ "$NUM" "$KEY"
    done
}

# Drop all unused files interactively
annex_dropunused_interactive() {
  ! annex_bare || return 1
  local IFS="$(printf ' \t\n')"
  local REPLY; read -r -p "Delete unused files? (a/y/n/s) " REPLY
  if [ "$REPLY" = "a" -o "$REPLY" = "A" ]; then
    local LAST="$(git annex unused | awk '/SHA256E/ {a=$1} END{print a}')"
    git annex dropunused "$@" 1-$LAST
  elif [ "$REPLY" = "s" -o "$REPLY" = "S" ]; then
    annex_show_unused_key
  elif [ "$REPLY" = "y" -o "$REPLY" = "Y" ]; then
    local LAST="$(git annex unused | awk '/SHA256E/ {a=$1} END{print a}')"
    git annex unused | grep -F 'SHA256E' | 
      while read -r NUM KEY; do
        printf "Key: $KEY\nFile: "
        annex_fromkey "$KEY"
        echo
        read -r -p "Delete file $NUM/$LAST? (y/f/n) " REPLY < /dev/tty
        if [ "$REPLY" = "y" -o "$REPLY" = "Y" ]; then
          sh -c "git annex dropunused ""$@"" $NUM" &
          wait
        elif [ "$REPLY" = "f" -o "$REPLY" = "F" ]; then
          sh -c "git annex dropunused --force ""$@"" $NUM" &
          wait
        fi
        echo "~"
      done
  fi
}

########################################
# Clean log by rebuilding branch git-annex & master
# Similar to "git annex forget"
annex_cleanup() {
  # Stop on error
  ( set -e
    annex_exists || return 1
    if [ $(git_st | wc -l) -ne 0 ]; then
      echo "Some changes are pending. Abort ..."
      return 2
    fi
    # Confirmation
    local REPLAY; read -r -p "Cleanup git-annex? (y/n) " REPLY < /dev/tty
    [ "$REPLY" != "y" -a "$REPLY" != "Y" ] && return 3
    # Rebuild master branch
    git branch -m old-master
    git checkout --orphan master
    git add .
    git commit -m 'first commit'
    # Rebuild git-annex branch
    git branch -m git-annex old-git-annex
    git checkout old-git-annex
    git checkout --orphan git-annex
    git add .
    git commit -m 'first commit'
    git checkout master
    # Cleanup
    git branch -D old-master old-git-annex
    git reflog expire --expire=now --all
    git prune
    git gc
  )
}

# Forget a special remote
annex_forget_remote() {
  # Confirmation
  local REPLAY; read -r -p "Forget remotes (and cleanup git-annex history)? (y/n) " REPLY < /dev/tty
  [ "$REPLY" != "y" -a "$REPLY" != "Y" ] && return 3
  local OK=1
  for REMOTE; do
    git remote remove "$REMOTE" &&
    git annex dead "$REMOTE" ||
    OK=""
  done
  [ -n "$OK" ] && git annex forget --drop-dead --force
}

########################################
# Delete all versions of a file
# https://git-annex.branchable.com/tips/deleting_unwanted_files/
annex_purge() {
  annex_exists || return 1
  local IFS="$(printf ' \t\n')"
  for F; do
    echo "Delete file '$F' ? (y/n)"
    read REPLY </dev/tty
    [ "$REPLY" = "y" -o "$REPLY" = "Y" ] || continue
    git annex whereis "$F"
    git annex drop --force "$F"
    for R in $(annex_enabled); do
      git annex drop --force "$F" --from "$R"
    done
    rm "$F" 2>/dev/null
  done
  git annex sync
}

########################################
# Populate a special remote directory with files from the input source
# The current repository is used to find out keys & file names,
# but is not used directly to copy/move the files from
# Note the same backend than the source is used for the destination file names
# WHERE selects which files & repo to look for
# MOVE=1 moves files instead of copying them
alias annex_populate='MOVE= _annex_populate'
alias annex_populatem='MOVE=1 _annex_populate'
_annex_populate() {
  local DST="${1:?No dst directory specified...}"
  local SRC="${2:-$PWD}"
  local WHERE="${3:-${WHERE:---include '*'}}"
  eval git annex find "$WHERE" --format='\${file}\\000\${hashdirlower}\${key}/\${key}\\000' | xargs -r0 -n2 sh -c '
    DBG="$1"; MOVE="$2"; SRCDIR="$3; DSTDIR="$4"; SRC="$SRCDIR/$5"; DST="$DSTDIR/$6"
    echo "$SRC -> $DST"
    if [ -d "$SRCDIR" -o -d "$DSTDIR" ]; then
      if [ -n "$MOVE" ]; then
        if [ -r "$SRC" -a ! -h "$SRC" ]; then
          $DBG mkdir -p "$(dirname "$DST")"
          $DBG mv -f -T "$SRC" "$DST"
        else
          $DBG rsync -K -L --protect-args --remove-source-files "$SRC" "$DST"
        fi
      else
        $DBG rsync -K -L --protect-args "$SRC" "$DST"
      fi
    fi
  ' _ "${DBG:+echo [DBG]}" "$MOVE" "$SRC" "$DST"
}

########################################
# Set a remote key presence flag
# WHERE selects which files & repo to look for
# DBG enable debug mode
annex_setpresentkey() {
  local REMOTE="${1:?No remote specified...}"
  local WHERE="${2:-${WHERE:---include '*'}}"
  local PRESENT="${3:-1}"
  local UUID="$(git config --get remote.${REMOTE}.annex-uuid)"
  [ -z "$UUID" ] && { echo "Remote $REMOTE unknown...}" && return 1; }
  eval git annex find "$WHERE" --format='\${key}\\000' | xargs -r0 -n1 sh -c '
    DBG="$1"; UUID="$2"; PRESENT="$3"; KEY="$4"
    $DBG git annex setpresentkey "$KEY" "$UUID" $PRESENT
  ' _ "${DBG:+echo [DBG]}" "$UUID" "$PRESENT"
}

########################################
# Find duplicates
annex_duplicates() {
  git annex find --include '*' --format='${file} ${escaped_key}\n' | \
      sort -k2 | uniq --all-repeated=separate -f1 | \
      sed 's/ [^ ]*$//'
}

# Remove one duplicate
annex_rm_duplicates() {
  git annex find --include '*' --format='${file} ${escaped_key}\n' | \
      sort -k2 | uniq --repeated -f1 | sed 's/ [^ ]*$//' | \
      xargs -d '\n' git rm
}

########################################
########################################
# Last commands in file
# Execute function from command line
[ "${1#annex}" != "$1" ] && "$@" || true
