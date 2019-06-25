#!/bin/sh
set -e

gf="guestfish --remote"

# Download and prepare minimal system image
curl http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64/alpine-minirootfs-3.10.0-x86_64.tar.gz -o /tmp/alpine.tar.gz
virt-make-fs -s +50M -F qcow2 /tmp/alpine.tar.gz /tmp/alpine-minimal.qcow2

# Install Alpine Linux
eval "$(guestfish --listen --network)"
$gf add-drive /tmp/alpine-minimal.qcow2
$gf disk-create /tmp/image.qcow2 qcow2 1G
$gf add-drive /tmp/image.qcow2
$gf run
$gf part-disk /dev/sdb msdos
$gf mkfs-opts ext4 /dev/sdb1 features:^64bit
$gf part-set-bootable /dev/sdb 1 true
$gf mount /dev/sda /
$gf command "apk add --no-cache alpine-conf"
$gf mount /dev/sdb1 /mnt
$gf rm-rf /mnt/lost+found
$gf mkdir /mnt/boot
$gf command "setup-disk -k virt /mnt"

# Fix networking
$gf write /mnt/etc/network/interfaces "auto lo
iface lo inet loopback
"

# Enable setvices
$gf ln_s /etc/init.d/bootmisc /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/hostname /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/hwclock /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/modules /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/networking /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/swap /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/sysctl /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/syslog /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/urandom /mnt/etc/runlevels/boot/
$gf ln_s /etc/init.d/killprocs /mnt/etc/runlevels/shutdown/
$gf ln_s /etc/init.d/savecache /mnt/etc/runlevels/shutdown/
$gf ln_s /etc/init.d/mount-ro /mnt/etc/runlevels/shutdown/
$gf ln_s /etc/init.d/devfs /mnt/etc/runlevels/sysinit/
$gf ln_s /etc/init.d/dmesg /mnt/etc/runlevels/sysinit/
$gf ln_s /etc/init.d/hwdrivers /mnt/etc/runlevels/sysinit/
$gf ln_s /etc/init.d/mdev /mnt/etc/runlevels/sysinit/

# Finalizing
$gf umount /dev/sdb1
$gf umount /dev/sda
$gf exit
