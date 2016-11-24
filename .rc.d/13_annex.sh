#!/bin/sh

# Annex aliases
alias gana='git annex add'
alias gant='git annex status'
alias ganst='annex_st'
alias ganl='git annex list'
alias ganlc='git annex find | wc -l'
alias ganf='git annex find'
alias ganfc='git annex find | wc -l'
alias gans='git annex sync'
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
alias gannex='git annex'

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
  annex_exists && ! annex_direct && git_bare
}

# Init annex
annex_init() {
  git annex init "$(uname -n)"
}

# Uninit annex
annex_uninit() {
  git annex uninit && git config --replace-all core.bare false
}

# Init annex in direct mode
annex_init_direct() {
  annex_init && git annex direct
}

# Init hubic annex
annex_init_hubic() {
  local NAME="${1:-hubic}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=hubic hubic_container=annex hubic_path="$REMOTEPATH" embedcreds=no keyid+="$KEYID" ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=external externaltype=hubic hubic_container=annex hubic_path="$REMOTEPATH" embedcreds=no keyid="$KEYID" 
}

# Init gdrive annex
annex_init_gdrive() {
  local NAME="${1:-gdrive}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=external externaltype=googledrive folder="$REMOTEPATH" keyid+="$KEYID" ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=external externaltype=googledrive folder="$REMOTEPATH" keyid="$KEYID" 
}

# Init bup annex
annex_init_bup() {
  local NAME="${1:-bup}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=bup buprepo="$REMOTEPATH" keyid+="$KEYID" ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=bup buprepo="$REMOTEPATH" keyid="$KEYID" 
}

# Init rsync annex
annex_init_rsync() {
  local NAME="${1:-rsync}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=rsync rsyncurl="$REMOTEPATH" keyid+="$KEYID" ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=rsync rsyncurl="$REMOTEPATH" keyid="$KEYID"
  git config --add annex.sshcaching false
}

# Init gcrypt annex
annex_init_gcrypt() {
  local NAME="${1:-gcrypt}"
  local ENCRYPTION="${2:-none}"
  local REMOTEPATH="${3:-$(git_repo)}"
  local KEYID="$4"
  git annex enableremote "$NAME" encryption="$ENCRYPTION" type=gcrypt gitrepo="$REMOTEPATH" keyid+="$KEYID" ||
  git annex initremote   "$NAME" encryption="$ENCRYPTION" type=gcrypt gitrepo="$REMOTEPATH" keyid="$KEYID"
  git config --add annex.sshcaching false
}

# Annex sync
annex_sync() {
  git annex sync "$@"
}

# Annex sync content
alias annex_sync_content='annex_sync --content'
alias annex_sync_content_fast='annex_sync --content --fast'

# Annex status
annex_status() {
  echo "annex status:"
  git annex status
}

# Git status for scripts
annex_st() {
  git annex status | awk '/^[\? ]?'$1'[\? ]?/ {print "\""$2"\""}'
}

# Annex diff
annex_diff() {
  if ! annex_direct; then
    git diff "$@"
  fi
}

# Annex bundle
annex_bundle() {
  git_exists || return 1
  if annex_exists; then
    local DIR="${1:-$(git_dir)/bundle}"
    if [ -d "$DIR" ]; then
      local BUNDLE="$DIR/${2:-$(git_name "annex").tgz}"
      local GPG_RECIPIENT="$3"
      local GPG_TRUST="${4:+--trust-model always}"
      echo "Tar annex into $BUNDLE"
      if annex_bare; then
        tar zcf "${BUNDLE}" -h ./annex
      else
        git annex find | 
          awk '{print "\""$0"\""}' |
          xargs tar zcf "${BUNDLE}" -h --exclude-vcs --
      fi
      if [ ! -z "$GPG_RECIPIENT" ]; then
        gpg -v --output "${BUNDLE}.gpg" --encrypt --recipient "$GPG_RECIPIENT" $GPG_TRUST "${BUNDLE}" &&
          (shred -fu "${BUNDLE}" || wipe -f -- "${BUNDLE}" || rm -- "${BUNDLE}")
      fi
      ls -l "${BUNDLE}"*
    else
      echo "Target directory '$DIR' does not exists."
      echo "Skip bundle creation..."
    fi
  else
    echo "Repository '$(git_dir)' is not git-annex ready."
    echo "Skip bundle creation..."
  fi
}

# Annex get
alias annex_get_auto='git annex get --auto'
alias annex_get_fast='git annex get --fast'
alias annex_get_fast_auto='git annex get --fast --auto'
alias annex_get_missing='annex_missing | xargs annex_get'

# Annex copy
alias annex_copy_all='annex_copy --all'
alias annex_copy_auto='annex_copy --auto'
alias annex_copy_fast='annex_copy --fast'
alias annex_copy_fast_auto='annex_copy --fast --auto'
annex_copy() {
  annex_exists || return 1
  for LAST; do true; done
  if [ "$LAST" = "--from" ] || [ "$LAST" = "--to" ]; then
    for REMOTE in $(git_remotes); do
      git annex copy "$@" "$REMOTE"
    done
  else
    git annex copy "$@"
  fi
}

# Annex download
alias annex_download='annex_copy --from'
alias annex_download_fast='annex_copy_fast --from'
alias annex_download_all='annex_copy_all --from'
alias annex_download_auto='annex_copy_auto --from'
alias annex_download_fast_auto='annex_copy_fast_auto --from'

# Annex upload
alias annex_upload='annex_copy --to'
alias annex_upload_fast='annex_copy_fast --to'
alias annex_upload_all='annex_copy_all --to'
alias annex_upload_auto='annex_copy_auto --to'
alias annex_upload_fast_auto='annex_copy_fast_auto --to'

# Annex upkeep
annex_upkeep() {
  annex_exists || return 1
  # Get args
  local ADD=""
  local SYNC=""
  local DL=""
  local UL=""
  local MSG="[upkeep] auto-commit"
  local FLAG OPTIND OPTARG
  while getopts "vasdum" FLAG; do
    case "$FLAG" in
      v) git annex status;;
      a) ADD=1; annex_direct && SYNC=1;;
      s) SYNC=1;;
      d) DL=1;;
      u) UL=1;;
      m) MSG="$OPTARG";;
    esac
  done
  # Run
  if [ -n "$ADD" ]; then
    git annex add . --fast
    if ! annex_direct; then
      git commit -m "$MSG"
    fi
  fi
  if [ -n "$SYNC" ]; then
    git annex sync
  fi
  if [ -n "$DL" ]; then
    git annex get
  fi
  if [ -n "$UL" ]; then
    annex_upload_fast
  fi
}

# Find aliases
alias annex_wantget='git annex find --want-get --not --in'
alias annex_wantdrop='git annex find --want-drop --in'
alias annex_present='git annex find'
alias annex_absent='git annex find --not --in=here'
alias annex_missing='git annex list | grep "^_+ "'

# Find annex repositories
annex_find() {
	ff_git0 "${1:-.}" |
		while read -d $'\0' DIR; do
			annex_exists "$DIR" && printf "'%s'\n" "$DIR"
		done 
}

# Fsck/check all
alias annex_fsck='annex_find | xargs -I {} -n 1 sh -c "cd \"{}/..\"; pwd; git annex fsck"'
alias annex_check='annex_find | xargs -I {} -n 1 sh -c "cd \"{}/..\"; pwd; git annex list | grep \"^_\""'

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

########################################
########################################
# Last commands in file
# Execute function from command line
[ $# -gt 0 -a ! -z "$1" ] && "$@" || true
