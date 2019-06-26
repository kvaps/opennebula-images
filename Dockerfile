FROM ubuntu:18.04 as image-builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
 && apt-get clean

ADD functions.sh mkimage.* /

FROM image-builder as alpine-3.10
RUN ./mkimage.alpine "https://alpine.global.ssl.fastly.net/alpine/v3.10/releases/x86_64/alpine-minirootfs-3.10.0-x86_64.tar.gz" "/alpine-3.10.qcow2"

FROM image-builder as ubuntu-16.04
RUN ./mkimage.ubuntu "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img" "/ubuntu-16.04.qcow2"

FROM image-builder as debiam-9
RUN ./mkimage.debian "https://cdimage.debian.org/cdimage/openstack/current/debian-9.9.3-20190618-openstack-amd64.qcow2" "/debian-9.qcow2"

FROM image-builder as devuan-2
RUN ./mkimage.debian "https://mirror.leaseweb.com/devuan/devuan_ascii/virtual/devuan_ascii_2.0.0_amd64_qemu.qcow2.xz" "/devuan-2.qcow2" 2G

FROM image-builder as centos-7
RUN ./mkimage.centos "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c" "/centos-7.qcow2"

FROM image-builder as fedora-30
RUN ./mkimage.fedora "https://download.fedoraproject.org/pub/fedora/linux/releases/30/Cloud/x86_64/images/Fedora-Cloud-Base-30-1.2.x86_64.qcow2" "/fedora-30.qcow2"

FROM image-builder as opensuse-leap-15
RUN ./mkimage.opensuse "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.1/images/openSUSE-Leap-15.1-OpenStack.x86_64.qcow2" "/opensuse-leap-15.qcow2"
