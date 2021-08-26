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
RUN yum -y install https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.2/one-context-5.12.0.2-1.el7.noarch.rpm
RUN yum clean all

RUN sed -i /etc/ssh/sshd_config \
      -e 's/#\?PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/'

RUN printf "%s\n" \
      'GRUB_TIMEOUT=1' \
      'GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200 biosdevname=0 net.ifnames=0"' \
      'GRUB_TERMINAL="console serial"' \
      'GRUB_SERIAL_COMMAND="serial --speed=115200"' \
      > /etc/default/grub

# ------------------------------------------------------------------------------
FROM image-builder as centos-7-image
COPY --from=centos-7-root / /rootfs
RUN cat onesysprep | chroot /rootfs sh -s - --yes --operations default,-one-trim \
 && rm -rf /rootfs/run/* \
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

COPY --from=centos-7-image /image.qcow2 /centos-7.qcow2
