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
RUN yum -y groupinstall \
      "Base" \
      "Minimal Install" \
 && rm -rf /boot/initramfs-*
RUN yum -y install \
      grub2 \
      epel-release
RUN yum -y install https://github.com/OpenNebula/addon-context-linux/releases/download/v6.0.0/one-context-6.0.0-1.el7.noarch.rpm
RUN yum clean all

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

RUN printf "%s\n" \
      'GRUB_TIMEOUT=1' \
      'GRUB_CMDLINE_LINUX_DEFAULT="biosdevname=0 net.ifnames=0"' \
      > /etc/default/grub

# ------------------------------------------------------------------------------
# Ubuntu 20.04
# ------------------------------------------------------------------------------
FROM ubuntu:20.04 as ubuntu-20.04-root
ARG DEBIAN_FRONTEND=noninteractive

RUN echo "link_in_boot = YES" > /etc/kernel-img.conf
RUN apt-get update \
 && apt-get install -y \
      ubuntu-minimal \
      ubuntu-standard \
      linux-image-generic \
 && wget -O /one-context.deb https://github.com/OpenNebula/addon-context-linux/releases/download/v6.0.0/one-context_6.0.0-1.deb \
 && dpkg -i /one-context.deb || apt-get install -fy \
 && rm -f /one-context.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN printf "%s\n" \
      'GRUB_TIMEOUT=1' \
      'GRUB_CMDLINE_LINUX_DEFAULT="biosdevname=0 net.ifnames=0"' \
      > /etc/default/grub


RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# ------------------------------------------------------------------------------
# Debian
# ------------------------------------------------------------------------------
FROM debian:11 as debian-11-root
ARG DEBIAN_FRONTEND=noninteractive

RUN echo "link_in_boot = YES" > /etc/kernel-img.conf
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
 && wget -O /one-context.deb https://github.com/OpenNebula/addon-context-linux/releases/download/v6.0.0/one-context_6.0.0-1.deb \
 && dpkg -i /one-context.deb || apt-get install -fy \
 && rm -f /one-context.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN printf "%s\n" \
      'GRUB_TIMEOUT=1' \
      'GRUB_CMDLINE_LINUX_DEFAULT="biosdevname=0 net.ifnames=0"' \
      > /etc/default/grub

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

# ------------------------------------------------------------------------------
# Alpine
# ------------------------------------------------------------------------------
FROM alpine:3.14 as alpine-3.14-root

RUN apk add --no-cache --no-scripts \
      alpine-base \
      linux-virt \
      grub \
      grub-bios \
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

RUN wget -O /one-context.apk https://github.com/OpenNebula/addon-context-linux/releases/download/v6.0.0/one-context-6.0.0-r1.apk \
 && apk add --no-cache --allow-untrusted /one-context.apk \
 && rm -f /one-context.apk

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/' \
 && sed -i /etc/passwd -e 's/root:!:/root:x:/' \
 && sed -i /etc/shadow -e 's/root:!:/root:*:/'

RUN printf "%s\n" \
      'GRUB_TIMEOUT=1' \
      'GRUB_CMDLINE_LINUX_DEFAULT="biosdevname=0 net.ifnames=0"' \
      > /etc/default/grub

# Serial console
#RUN printf "%s\n" \
#      'GRUB_TIMEOUT=1' \
#      'GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200 biosdevname=0 net.ifnames=0"' \
#      'GRUB_TERMINAL="console serial"' \
#      'GRUB_SERIAL_COMMAND="serial --speed=115200"' \
#      > /etc/default/grub
#RUN printf "%s\n" "" \
#      '# enable login on alternative console' \
#      'ttyS0::respawn:/sbin/getty -L 0 ttyS0 vt100' \
#      >> /etc/inittab

# ------------------------------------------------------------------------------
FROM image-builder as centos-7-image
COPY --from=centos-7-root / /rootfs
RUN cat onesysprep | chroot /rootfs sh -s - --yes --operations default,-one-trim \
 && rm -rf /rootfs/run/* \
 && ln -sf ../proc/self/mounts /rootfs/etc/mtab \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /rootfs /image.qcow2 \
 && qemu-img resize /image.qcow2 2G \
 && guestfish -a /image.qcow2 -- run \
      : part-set-bootable /dev/sda 1 true \
      : part-resize /dev/sda 1 -1 \
      : resize2fs /dev/sda1 \
      : mount /dev/sda1 / \
      : write /etc/fstab 'LABEL=rootfs   /        ext4   defaults        0 1' \
      : sh 'KERNEL=$(ls -t1 /lib/modules|head -n1) && dracut -f "/boot/initramfs-$KERNEL.img" "$KERNEL"' \
      : command 'grub2-install /dev/sda' \
      : command 'grub2-mkconfig -o /boot/grub2/grub.cfg' \
      : umount-all \
      : exit

# ------------------------------------------------------------------------------
FROM image-builder as ubuntu-20.04-image
COPY --from=ubuntu-20.04-root / /rootfs
RUN cat onesysprep | chroot /rootfs sh -s - --yes --operations default,-one-trim \
 && rm -rf /rootfs/run/* \
 && ln -sf ../proc/self/mounts /rootfs/etc/mtab \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /rootfs /image.qcow2 \
 && qemu-img resize /image.qcow2 2G \
 && guestfish -a /image.qcow2 -- run \
      : part-set-bootable /dev/sda 1 true \
      : part-resize /dev/sda 1 -1 \
      : resize2fs /dev/sda1 \
      : mount /dev/sda1 / \
      : write /etc/fstab 'LABEL=rootfs   /        ext4   defaults        0 1' \
      : sh 'update-initramfs -u -k "$(ls -t1 /lib/modules|head -n1)"' \
      : command 'grub-install /dev/sda' \
      : command 'update-grub' \
      : umount-all \
      : exit

# ------------------------------------------------------------------------------
FROM image-builder as debian-11-image
COPY --from=debian-11-root / /rootfs
RUN cat onesysprep | chroot /rootfs sh -s - --yes --operations default,-one-trim \
 && rm -rf /rootfs/run/* \
 && ln -sf ../proc/self/mounts /rootfs/etc/mtab \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /rootfs /image.qcow2 \
 && qemu-img resize /image.qcow2 2G \
 && guestfish -a /image.qcow2 -- run \
      : part-set-bootable /dev/sda 1 true \
      : part-resize /dev/sda 1 -1 \
      : resize2fs /dev/sda1 \
      : mount /dev/sda1 / \
      : write /etc/fstab 'LABEL=rootfs   /        ext4   defaults        0 1' \
      : sh 'update-initramfs -u -k "$(ls -t1 /lib/modules|head -n1)"' \
      : command 'grub-install /dev/sda' \
      : command 'update-grub' \
      : umount-all \
      : exit

# ------------------------------------------------------------------------------
FROM image-builder as alpine-3.14-image
COPY --from=alpine-3.14-root / /rootfs
RUN cat onesysprep | chroot /rootfs sh -s - --yes --operations default,-one-trim \
 && rm -rf /rootfs/run/* \
 && ln -sf ../proc/self/mounts /rootfs/etc/mtab \
 && virt-make-fs -s +100M -F qcow2 --partition=mbr --type=ext4 --label=rootfs /rootfs /image.qcow2 \
 && qemu-img resize /image.qcow2 512M \
 && guestfish -a /image.qcow2 -- run \
      : part-set-bootable /dev/sda 1 true \
      : part-resize /dev/sda 1 -1 \
      : resize2fs /dev/sda1 \
      : mount /dev/sda1 / \
      : sh 'sed -i /etc/default/grub -e /GRUB_CMDLINE_LINUX_DEFAULT=/s/\"/\"rootfstype=ext4\ /' \
      : write /etc/fstab "LABEL=rootfs   /        ext4   defaults        0 1" \
      : sh 'mkinitfs "$(ls -t1 /lib/modules | head -n1)"' \
      : command 'grub-install /dev/sda' \
      : command 'grub-mkconfig -o /boot/grub/grub.cfg' \
      : umount-all \
      : exit

FROM ubuntu:20.04 as all-images
COPY --from=centos-7-image /image.qcow2 /centos-7.qcow2
COPY --from=ubuntu-20.04-image /image.qcow2 /ubuntu-20.04.qcow2
COPY --from=debian-11-image /image.qcow2 /debian-11.qcow2
COPY --from=alpine-3.14-image /image.qcow2 /alpine-3.14.qcow2
