#!/bin/sh
set -e

gf="guestfish --remote"

# Download cloud image
curl -L https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.1/images/openSUSE-Leap-15.1-OpenStack.x86_64.qcow2 -o /tmp/opensuse.qcow2

# Prepare new image
eval "$(guestfish --listen)"
$gf disk-create /tmp/image.qcow2 qcow2 2G
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
guestfish --ro -a /tmp/opensuse.qcow2 -m /dev/sda1 -- tar-out / - | \
 guestfish --rw -a /tmp/image.qcow2 -m /dev/sda1 -- tar-in - /

# Fix fstab and bootloader
eval "$(guestfish --listen)"
$gf add-drive /tmp/image.qcow2
$gf run
$gf mount /dev/sda1 /
$gf write /etc/fstab "LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
"
$gf command "grub2-install /dev/sda"
$gf command "sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"console=ttyS0,115.10n8 console=tty0 net.ifnames=0 NON_PERSISTENT_DEVICE_NAMES=1\"/' /etc/default/grub"
$gf command "grub2-mkconfig -o /boot/grub2/grub.cfg"

# Finalizing
$gf umount /dev/sda1
$gf exit

GRUB_CMDLINE_LINUX_DEFAULT=""
