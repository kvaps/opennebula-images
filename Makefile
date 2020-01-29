export LIBGUESTFS_BACKEND=direct
export LIBGUESTFS_MEMSIZE=2048
export TIMEZONE=UTC

.PHONY: all clean

all: \
	images/alpine-3.11.qcow2 \
	images/ubuntu-16.04.qcow2 \
	images/ubuntu-18.04.qcow2 \
	images/debian-9.qcow2 \
	images/devuan-2.qcow2 \
	images/centos-6.qcow2 \
	images/centos-7.qcow2 \
	images/centos-8.qcow2 \
	images/fedora-30.qcow2 \
	images/fedora-31.qcow2 \
	images/opensuse-leap-15.qcow2

clean:
	rm -rf images/*


images/alpine-3.10.qcow2:
	./mkimage.alpine "$@" 500M \
	  "https://alpine.global.ssl.fastly.net/alpine/v3.10/releases/x86_64/alpine-minirootfs-3.10.4-x86_64.tar.gz"

images/alpine-3.11.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.11/releases/x86_64/alpine-minirootfs-3.11.4-x86_64.tar.gz"

images/ubuntu-16.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"

images/ubuntu-18.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img" \

images/debian-9.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cdimage.debian.org/cdimage/openstack/current/debian-9.9.3-20190618-openstack-amd64.qcow2"

images/debian-10.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cdimage.debian.org/cdimage/openstack/current/debian-10.0.1-20190708-openstack-amd64.qcow2"

images/devuan-2.qcow2:
	./mkimage.devuan "$@" 2G \
		"https://mirror.leaseweb.com/devuan/devuan_ascii/virtual/devuan_ascii_2.0.0_amd64_qemu.qcow2.xz"

images/centos-6.qcow2:
	./mkimage.centos6 "$@" 2G \
		"https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2c"

images/centos-7.qcow2:
	./mkimage.centos7 "$@" 2G \
		"https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c"

images/centos-8.qcow2:
	./mkimage.centos8 "$@" 2G \
    "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"

images/fedora-30.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/30/Cloud/x86_64/images/Fedora-Cloud-Base-30-1.2.x86_64.qcow2"

images/fedora-31.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/31/Cloud/x86_64/images/Fedora-Cloud-Base-31-1.9.x86_64.qcow2"

images/opensuse-leap-15.qcow2:
	./mkimage.opensuse "$@" 2G \
		"https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.2/images/openSUSE-Leap-15.2-OpenStack.x86_64.qcow2"
