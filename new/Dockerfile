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

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# TODO: Cleanup SSH-keys

# ------------------------------------------------------------------------------
# Ubuntu 20.04
# ------------------------------------------------------------------------------
FROM ubuntu:20.04 as ubuntu2004-root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y \
      ubuntu-minimal \
      ubuntu-standard \
      linux-image-kvm \
 && wget -O /one-context.deb https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.2/one-context_5.12.0.2-1.deb \
 && dpkg -i /one-context.deb || apt-get install -fy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# TODO: Cleanup SSH-keys

# ------------------------------------------------------------------------------
# Debian
# ------------------------------------------------------------------------------
FROM debian:11 as debian11-root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
      aptitude \
 && aptitude -y install ~pstandard ~pimportant ~prequired task-ssh-server \
 && wget -O /one-context.deb https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.2/one-context_5.12.0.2-1.deb \
 && dpkg -i /one-context.deb || apt-get install -fy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# TODO: Cleanup SSH-keys

# ------------------------------------------------------------------------------
FROM guestfish as images
COPY --from=centos7-root / /centos7-root
COPY --from=ubuntu2004-root / /ubuntu2004-root
COPY --from=debian11-root / /debian11-root

RUN for root in \
      centos7-root \
      ubuntu2004-root \
      debian11-root \
    ; do rm -rf /$root/run/* \
      && echo localhost > /$root/etc/hostname \
      && printf "%blocalhost localhost.localdomain\n" "127.0.0.1\t" "::1\t\t" > /$root/etc/hosts \
      && ln -sf /run/systemd/resolve/stub-resolv.conf /$root/etc/resolv.conf \
    ; done

RUN virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /centos7-root /centos7.qcow2 \
 && qemu-img resize /image.qcow2 3G \
 && eval $(guestfish --listen --network -a centos7.qcow2) \
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

RUN virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /ubuntu2004-root /ubuntu2004.qcow2 \
 && qemu-img resize /image.qcow2 3G \
 && eval $(guestfish --listen --network -a ubuntu2004.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && KERNEL=$(guestfish --remote -- command "ls -t1 /lib/modules" | head -n1) \
 && guestfish --remote -- command "dracut -f /boot/initramfs-$KERNEL.img $KERNEL" \
 && guestfish --remote -- command "grub-install /dev/sda" \
 && guestfish --remote -- command "update-grub" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit

RUN virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /debian11-root /debian11.qcow2 \
 && qemu-img resize /image.qcow2 3G \
 && eval $(guestfish --listen --network -a ubuntu2004.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && KERNEL=$(guestfish --remote -- command "ls -t1 /lib/modules" | head -n1) \
 && guestfish --remote -- command "dracut -f /boot/initramfs-$KERNEL.img $KERNEL" \
 && guestfish --remote -- command "grub-install /dev/sda" \
 && guestfish --remote -- command "update-grub" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit
