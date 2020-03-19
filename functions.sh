#!/bin/sh

download() {
  local src=$1 dst=$2
  case "${src%%:*}" in
  http|https|ftp)
    curl -f -L "$src" -o "$dst" 2>&1
    ;;
  *)
    cp "$src" "$dst"
    ;;
  esac
}

download_and_unpack() {
  local src=$1 dst=$2
  download "$src" "$dst"

  local mimetype=$(file -b --mime-type "$dst")

  case "$mimetype" in
    application/gzip )
      mv "$dst" "$dst.gz"
      gunzip "$dst.gz"
    ;;
    application/x-xz )
      mv "$dst" "$dst.xz"
      xz --decompress "$dst.xz"
    ;;
  esac
}

create_empty_image() {
  local dst=$1 size=$2

  guestfish \
      disk-create "$dst" qcow2 "$size" \
    : add-drive "$dst" \
    : run \
    : part-disk /dev/sda msdos \
    : mkfs-opts ext4 /dev/sda1 features:^64bit \
    : set-e2label /dev/sda1 cloudimg-rootfs \
    : part-set-bootable /dev/sda 1 true \
    : mount /dev/sda1 / \
    : rm-rf /lost+found \
    : umount /dev/sda1 \
    : exit
}

copy_fs() {
  local src_image=$1 src_dev=$2 src_path=$3 dst_image=$4 dst_dev=$5 dst_path=$6

  guestfish --ro -a $src_image -m $src_dev -- tar-out $src_path - | \
    guestfish --rw -a $dst_image -m $dst_dev -- tar-in - $dst_path
}

gf() {
  guestfish --remote "${@}"
}

gf_listen() {
  eval "$(guestfish --listen --network)"
}
