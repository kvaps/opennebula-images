#!/bin/sh
set -e

gf="guestfish --remote"

# Download cloud image
curl -L https://cdimage.debian.org/cdimage/openstack/current/debian-9.9.3-20190618-openstack-amd64.qcow2 -o /tmp/debian.qcow2

# Prepare new image
eval "$(guestfish --listen)"
$gf disk-create /tmp/image.qcow2 qcow2 1G
$gf add-drive /tmp/image.qcow2
$gf run
$gf part-disk /dev/sda msdos
$gf mkfs-opts ext4 /dev/sda1 features:^64bit
$gf set-e2label /dev/sda1 cloudimg-rootfs
$gf part-set-bootable /dev/sda 1 true
$gf mount /dev/sda1 /
$gf rm-rf /lost+found
$gf umount /dev/sda1
$gf exit

# Copy base system
guestfish --ro -a /tmp/debian.qcow2 -m /dev/sda1 -- tar-out / - | \
 guestfish --rw -a /tmp/image.qcow2 -m /dev/sda1 -- tar-in - /

# Fix fstab and bootloader
eval "$(guestfish --listen)"
$gf add-drive /tmp/image.qcow2
$gf run
$gf mount /dev/sda1 /
$gf write /etc/fstab "LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
"
$gf command "grub-install /dev/sda"
$gf command "update-grub"

# Finalizing
$gf umount /dev/sda1
$gf exit
