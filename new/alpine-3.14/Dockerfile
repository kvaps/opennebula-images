ARG TOOLBOX_IMAGE

FROM alpine:3.14 as rootfs

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

FROM $TOOLBOX_IMAGE as image
COPY --from=rootfs / /rootfs
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

FROM scratch
COPY --from=image /image.qcow2 /image.qcow2
