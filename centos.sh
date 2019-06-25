#!/bin/sh
set -e

gf="guestfish --remote"

# Download cloud image
curl https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c -o /tmp/CentOS-7-x86_64-GenericCloud.qcow2c

# Prepare new image
eval "$(guestfish --listen)"
$gf disk-create /tmp/image.qcow2 qcow2 1G
$gf add-drive /tmp/image.qcow2
$gf run
$gf part-disk /dev/sda msdos
$gf mkfs-opts ext4 /dev/sda1 features:^64bit
$gf part-set-bootable /dev/sda 1 true
$gf mount /dev/sda1 /
$gf rm-rf /lost+found
$gf umount /dev/sda1
$gf exit

# Copy base system
guestfish --ro -a /tmp/CentOS-7-x86_64-GenericCloud.qcow2c -m /dev/sda1 -- tar-out / - | \
 guestfish --rw -a /tmp/image.qcow2 -m /dev/sda1 -- tar-in - /

# Fix fstab and bootloader
eval "$(guestfish --listen)"
$gf add-drive /tmp/image.qcow2
$gf run
UUID="$($gf get-uuid /dev/sda1)"
$gf mount /dev/sda1 /
$gf write /etc/fstab "UUID=$UUID / ext4 defaults 0 1
"
$gf command "grub2-install /dev/sda"
$gf command "grub2-mkconfig -o /boot/grub2/grub.cfg"

# Finalizing
$gf umount /dev/sda1
$gf exit
