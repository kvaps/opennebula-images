# ------------------------------------------------------------------------------
# Guestfish
# ------------------------------------------------------------------------------
FROM ubuntu:20.04 as image-builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
     make \
     bash-completion \
 && apt-get clean
RUN wget https://raw.githubusercontent.com/OpenNebula/addon-context-linux/v6.0.0/src/usr/sbin/onesysprep

# ------------------------------------------------------------------------------
# Centos 7
# ------------------------------------------------------------------------------
FROM centos:7 as centos-7-root
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

# ------------------------------------------------------------------------------
# Ubuntu 20.04
# ------------------------------------------------------------------------------
FROM ubuntu:20.04 as ubuntu-20.04-root
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

# ------------------------------------------------------------------------------
# Debian
# ------------------------------------------------------------------------------
FROM debian:11 as debian-11-root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
      aptitude \
 && aptitude install -y \
      ~pstandard \
      ~pimportant \
      ~prequired \
      task-ssh-server \
      linux-image-generic \
      grub2 \
 && wget -O /one-context.deb https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.2/one-context_5.12.0.2-1.deb \
 && dpkg -i /one-context.deb || apt-get install -fy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# ------------------------------------------------------------------------------
# Alpine
# ------------------------------------------------------------------------------
FROM alpine:3.14 as alpine-3.14-root

RUN apk add --no-cache \
      alpine-base \
      linux-virt \
      syslinux \
      e2fsprogs \
      openrc \
      openssl \
      openssh \
      tzdata
RUN printf "%s\n" "auto lo" "iface lo inet loopback" > /etc/network/interfaces \
 && ln -s /etc/init.d/bootmisc /etc/runlevels/boot/ \
 && ln -s /etc/init.d/hostname /etc/runlevels/boot/ \
 && ln -s /etc/init.d/hwclock /etc/runlevels/boot/ \
 && ln -s /etc/init.d/modules /etc/runlevels/boot/ \
 && ln -s /etc/init.d/networking /etc/runlevels/boot/ \
 && ln -s /etc/init.d/swap /etc/runlevels/boot/ \
 && ln -s /etc/init.d/sysctl /etc/runlevels/boot/ \
 && ln -s /etc/init.d/syslog /etc/runlevels/boot/ \
 && ln -s /etc/init.d/urandom /etc/runlevels/boot/ \
 && ln -s /etc/init.d/killprocs /etc/runlevels/shutdown/ \
 && ln -s /etc/init.d/savecache /etc/runlevels/shutdown/ \
 && ln -s /etc/init.d/devfs /etc/runlevels/sysinit/ \
 && ln -s /etc/init.d/dmesg /etc/runlevels/sysinit/ \
 && ln -s /etc/init.d/hwdrivers /etc/runlevels/sysinit/ \
 && ln -s /etc/init.d/mdev /etc/runlevels/sysinit/ \
 && ln -s /etc/init.d/sshd /etc/runlevels/default/

RUN wget -O /one-context.apk https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.1/one-context-5.12.0.1-r1.apk \
 && apk add --allow-untrusted /one-context.apk \
 && rm -f /one-context.apk

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/' \
 && sed -i /etc/passwd -e 's/root:!:/root:x:/' \
 && sed -i /etc/shadow -e 's/root:!:/root:*:/'

# ------------------------------------------------------------------------------
FROM image-builder as centos-7-image
COPY --from=centos-7-root / /centos-7-root
RUN IMAGE=centos-7 \
 && cat onesysprep | chroot /$IMAGE-root sh -s - --yes --operations default,-one-trim \
 && rm -rf /$IMAGE-root/run/* \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /$IMAGE-root /$IMAGE.qcow2 \
 && qemu-img resize /$IMAGE.qcow2 2G \
 && eval $(guestfish --listen --network -a $IMAGE.qcow2) \
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

# ------------------------------------------------------------------------------
FROM image-builder as ubuntu-20.04-image
COPY --from=ubuntu-20.04-root / /ubuntu-20.04-root
RUN IMAGE=ubuntu-20.04 \
 && cat onesysprep | chroot /$IMAGE-root sh -s - --yes --operations default,-one-trim \
 && rm -rf /$IMAGE-root/run/* \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /$IMAGE-root /$IMAGE.qcow2 \
 && qemu-img resize /$IMAGE.qcow2 1G \
 && eval $(guestfish --listen --network -a $IMAGE.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && guestfish --remote -- command "grub-install /dev/sda" \
 && guestfish --remote -- command "update-grub" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit

# ------------------------------------------------------------------------------
FROM image-builder as debian-11-image
COPY --from=debian-11-root / /debian-11-root
RUN IMAGE=debian-11 \
 && cat onesysprep | chroot /$IMAGE-root sh -s - --yes --operations default,-one-trim \
 && rm -rf /$IMAGE-root/run/* \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /$IMAGE-root /$IMAGE.qcow2 \
 && qemu-img resize /$IMAGE.qcow2 2G \
 && eval $(guestfish --listen --network -a $IMAGE.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && guestfish --remote -- command "grub-install /dev/sda" \
 && guestfish --remote -- command "update-grub" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit

# ------------------------------------------------------------------------------
FROM image-builder as alpine-3.14-image
COPY --from=alpine-3.14-root / /alpine-3.14-root
RUN IMAGE=alpine-3.14 \
 && cat onesysprep | chroot /$IMAGE-root sh -s - --yes --operations default,-one-trim \
 && rm -rf /$IMAGE-root/run/* \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /$IMAGE-root /$IMAGE.qcow2 \
 && qemu-img resize /$IMAGE.qcow2 512M \
 && eval $(guestfish --listen --network -a $IMAGE.qcow2) \
 && guestfish --remote -- run \
 && guestfish --remote -- part-resize /dev/sda 1 -1 \
 && guestfish --remote -- resize2fs /dev/sda1 \
 && guestfish --remote -- mount /dev/sda1 / \
 && guestfish --remote -- command "dd bs=440 count=1 conv=notrunc if=/usr/share/syslinux/mbr.bin of=/dev/sda" \
 && guestfish --remote -- command "extlinux --install /boot" \
 && guestfish --remote -- command "update-extlinux" \
 && guestfish --remote -- write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
 && guestfish --remote -- umount-all \
 && guestfish --remote -- exit

FROM ubuntu:20.04 as all-images
