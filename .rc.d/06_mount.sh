#!/bin/sh

# Mount ecryptfs
mount_ecryptfs() {
  local SRC="${1:?Missing source directory...}"
  local DST="${2:?Missing dest directory...}"
  local KEY1="${3:?Missing content key...}"
  local KEY2="${4:-$KEY1}"
  local CIPHER="${5:-aes}"
  local KEYLEN="${6:-32}"
  shift $(min 6 $#)
  local OPT="key=passphrase,ecryptfs_enable_filename_crypto=yes,no_sig_cache=yes,ecryptfs_passthrough=no${@:+,$@}"
  OPT="ecryptfs_cipher=$CIPHER,ecryptfs_key_bytes=$KEYLEN,ecryptfs_sig=$KEY1,ecryptfs_fnek_sig=$KEY1,ecryptfs_unlink_sigs${OPT:+,$OPT}"
  chmod 500 "$SRC"
  sudo ecryptfs-add-passphrase --fnek
  sudo mount -i -t ecryptfs -o "$OPT" "$SRC" "$DST"
  chmod 700 "$DST"
}

# Mount encfs
mount_encfs() {
  local SRC="${1:?Missing source directory...}"
  local DST="${2:?Missing dest directory...}"
  local KEY="${3:?Missing encfs key...}"
  local PASSFILE="${4}"
  shift $(min 4 $#)
  ENCFS6_CONFIG="$(readlink -f "$KEY")" encfs -o nonempty ${PASSFILE:+--extpass='cat "$PASSFILE"'} "$@" "$SRC" "$DST"
}

# Mount iso
mount_iso() {
  sudo mount -o loop -t iso9660 "$@"
}

# NFS unmount
alias nfs-umountall='umount -a -t nfs'
nfs_umount() {
  local MOUNTPOINT="${1:?NFS mount point not specified...}"
  local IP="${2:?NFS IP not specified...}"
  local ITF="${3:-eth0}"
  local TMPFS="${4:-nfstmp}"
  #local TMPFS="${4:-fakenfs}"
  sudo sh -c "
    ifconfig $ITF:$TMPFS $IP netmask 255.255.255.255
    umount -f -l \"$MOUNTPOINT\"
    ifconfig $ITF:$TMPFS down
  "
}
