ARG TOOLBOX_IMAGE

FROM centos:7 as rootfs
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

ARG TOOLBOX_IMAGE
FROM $TOOLBOX_IMAGE as image
COPY --from=rootfs / /rootfs
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

FROM scratch
COPY --from=image /image.qcow2 /image.qcow2
