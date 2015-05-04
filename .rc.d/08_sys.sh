#!/bin/sh

################################
# Syslog
alias syslog='sudo tail /var/log/syslog'

# Processes
alias psf='ps -faux'
alias psd='ps -ef'
alias psg='ps -ef | grep -i'
alias psu='ps -fu $USER'
alias pg='pgrep -fl'
alias pgu='pgrep -flu $(id -u $USER)'

pid() {
  for NAME; do
    ps -C "$@" -o pid=
  done
}

uid() {
  for NAME; do
    ps -C "$@" -o user=
  done
}

################################
# System information
sys_iostat() {
  iostat -x 2
}

sys_stalled() {
  while true; do ps -eo state,pid,cmd | grep "^D"; echo "—-"; sleep 5; done
}

sys_cpu() {
  sar ${1:-1} ${2}
}

################################
# Memory information
mem() {
  free -mt --si
}

mem_free() {
  free | awk '{if (FNR==2){sum+=$4} else if (FNR==3){sum-=$4}} END {print sum}'
}

swap_free() {
  free | awk 'FNR==4 {print $4}'
}

mem_used() {
  free | awk '{if (FNR==2){sum+=$3} else if (FNR==3){sum-=$3}} END {print sum}'
}

swap_used() {
  free | awk 'FNR==4 {print $3}'
}

mem_total() {
  free | awk 'FNR==2 {print $2}'
}

swap_total() {
  free | awk 'FNR==4 {print $2}'
}

################################
# Processes information
alias cpu='cpu_ps'

cpu_ps() {
  # use eval because of the option "|" in $1
  eval ps aux ${1:+| grep $1} | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}'
}

mem_ps() {
  # use eval because of the option "|" in $1
  eval ps aux ${1:+| grep $1} | awk 'BEGIN {sum=0} {sum+=$4}; END {print sum}'
}

cpu_list() {
  local NUM=$((${1:-1} + 1))
  shift $(min 1 $#)
  # use eval because of the option "|" in $1
  eval ps ${@:-aux} --sort -%cpu ${NUM:+| head -n $NUM}
}

mem_list() {
  local NUM=$((${1:-1} + 1))
  shift $(min 1 $#)
  # use eval because of the option "|" in $1
  eval ps ${@:-aux} --sort -rss ${NUM:+| head -n $NUM}
}

cpu_listshort() {
  cpu_list "$1" ax -o comm,pid,%cpu,cpu
}

mem_listshort() {
  mem_list "$1" ax -o comm,pid,pmem,rss,vsz
}

kill_cpu() {
  local NUM=$((${1:-1} + 1))
  shift $(min 1 $#)
  ps a --sort -%cpu | awk 'NR>1 && NR<=$NUM {print $1;}' | xargs -r kill "$@"
}

kill_mem() {
  local NUM=$((${1:-1} + 1))
  shift $(min 1 $#)
  ps a --sort -rss | awk 'NR>1 && NR<=$NUM {print $1;}' | xargs -r kill "$@"
}

################################
# Keyboad layout
alias keyb-list='grep ^[^#] /etc/locale.gen'
alias keyb-set='setxkbmap -layout'
alias keyb-setfr='setxkbmap -layout fr'

################################
# Language selection functions
lang_fr() {
  export LANGUAGE="fr:en"
  export LC_ALL="fr_FR.UTF-8"
}
lang_en() {
  unset LANGUAGE
  export LC_ALL="en_US.UTF-8"
}

################################
# Cmd exist test
cmd_exists() {
  command -v ${1} >/dev/null
}

# Cmd unset
cmd_unset() {
  unalias $* 2>/dev/null
  unset -f $* 2>/dev/null
}

################################
# Chroot
mkchroot(){
  local SRC="/dev/${1:?Please specify the root device}"
  local DST="${2:-/mnt}"
  mount "$SRC" "$DST"
  mount --bind "/dev" "$DST/dev"
  mount --bind "/dev/pts" "$DST/dev/pts"
  mount -t sysfs "/sys" "$DST/sys"
  mount -t proc "/proc" "$DST/proc"
  chroot "$DST"
}

################################
# Make deb package from source
mkdeb() {
  local ARCHIVE="${1:?No input archive specified}"
  tar zxf "$ARCHIVE" || return 0
  cd "${ARCHIVE%.*}"
  ./configure || return 0
  dh_make -s -f "../$ARCHIVE"
  fakeroot debian/rules binary
}

################################
# Fstab to autofs conversion
fstab2autofs() {
  awk 'NF && substr($1,0,1)!="#" {print $2 "\t-fstype="$3 "," $4 "\t" $1}' "$@"
}

################################
# http://unix.stackexchange.com/questions/59112/preserve-directory-structure-when-moving-files-using-find
# Move/copy by replicating directory structure
_mkdir_exec() {
  local EXEC="${1:-echo}"
  local SRC="${2:-.}"
  local DST="$(path_abs "${3:-.}")"
  shift 3
  _ffind "$SRC" $@ -exec sh -c '
      EXEC="$1"
      shift
      for x do
        mkdir -p "$0/${x%/*}" &&
        $EXEC "$x" "$0/$x"
      done
    ' "$DST" "$EXEC" {} +
}
alias mkdir_cp='_mkdir_exec cp'
alias mkdir_mv='_mkdir_exec mv'

##############################
# Add ssh dedicated command id in ~/.ssh/authorized_keys
# Use ssh-copy-id for std login shells
ssh_copy_cmd_id() {
  ssh ${1:?No host specified} -p ${2:?No port specified...} -- sh -c "cat 'command=\"${3:?No command specified...},no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ${SSH_ORIGINAL_COMMAND#* }\" ${4:?No ssh key specified...}' >> '$HOME/.ssh/authorized_keys'"
}
