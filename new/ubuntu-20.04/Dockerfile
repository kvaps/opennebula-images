ARG TOOLBOX_IMAGE

FROM ubuntu:20.04 as rootfs
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
      : sh 'update-initramfs -u -k "$(ls -t1 /lib/modules|head -n1)"' \
      : command 'grub-install /dev/sda' \
      : command 'update-grub' \
      : umount-all \
      : exit

FROM scratch
COPY --from=image /image.qcow2 /image.qcow2
