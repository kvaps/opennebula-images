# ------------------------------------------------------------------------------
# Guestfish
# ------------------------------------------------------------------------------
FROM ubuntu:20.04 as guestfish

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
     make \
     bash-completion \
 && apt-get clean

# ------------------------------------------------------------------------------
# Centos 7
# ------------------------------------------------------------------------------
FROM centos:7 as centos7-root
RUN yum -y groupinstall "Base"
RUN yum -y install \
      grub2 \
      epel-release
RUN yum -y install https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.2/one-context-5.12.0.2-1.el7.noarch.rpm
RUN yum clean all \
 && rm -rf /boot/initramfs-*

RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# ------------------------------------------------------------------------------
FROM guestfish as centos7-image
COPY --from=centos7-root / /rootfs

RUN rm -rf /rootfs/run/* \
 && echo localhost > /rootfs/etc/hostname \
 && printf "%blocalhost localhost.localdomain\n" "127.0.0.1\t" "::1\t\t" > /rootfs/etc/hosts \
 && ln -sf /run/systemd/resolve/stub-resolv.conf /rootfs/etc/resolv.conf

RUN virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /rootfs /image.qcow2 \
 && qemu-img resize /image.qcow2 5G

RUN eval $(guestfish --listen --network -a image.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && KERNEL=$(guestfish --remote -- command "ls -t1 /lib/modules" | head -n1) \
 && guestfish --remote -- command "dracut -f /boot/initramfs-$KERNEL.img $KERNEL" \
 && guestfish --remote -- command "grub2-install /dev/sda" \
 && guestfish --remote -- command "grub2-mkconfig -o /boot/grub2/grub.cfg" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit
