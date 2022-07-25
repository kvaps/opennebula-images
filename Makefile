export LIBGUESTFS_BACKEND=direct
export LIBGUESTFS_MEMSIZE=2048

.PHONY: all clean

all: \
	images/alpine-3.13.qcow2 \
	images/alpine-3.14.qcow2 \
	images/alpine-3.15.qcow2 \
	images/alpine-3.16.qcow2 \
	images/ubuntu-18.04.qcow2 \
	images/ubuntu-20.04.qcow2 \
	images/ubuntu-22.04.qcow2 \
	images/debian-9.qcow2 \
	images/debian-10.qcow2 \
	images/debian-11.qcow2 \
	images/centos-7.qcow2 \
	images/centos-8-stream.qcow2 \
	images/centos-9-stream.qcow2 \
	images/fedora-34.qcow2 \
	images/fedora-35.qcow2 \
	images/fedora-36.qcow2 \

clean:
	rm -rf images/*

images/alpine-3.13.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.13/releases/x86_64/alpine-minirootfs-3.13.0-x86_64.tar.gz"

images/alpine-3.14.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.14/releases/x86_64/alpine-minirootfs-3.14.0-x86_64.tar.gz"

images/alpine-3.15.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.0-x86_64.tar.gz"

images/alpine-3.16.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.0-x86_64.tar.gz"

images/ubuntu-18.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img" \

images/ubuntu-20.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img" \

images/ubuntu-22.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img" \

images/debian-9.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2"

images/debian-10.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2"

images/debian-11.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"

images/centos-7.qcow2:
	./mkimage.centos7 "$@" 2G \
		"https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c"

images/centos-8-stream.qcow2:
	./mkimage.centos-stream "$@" 2G \
        "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20220125.1.x86_64.qcow2"

images/centos-9-stream.qcow2:
	./mkimage.centos-stream "$@" 2G \
        "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20220718.0.x86_64.qcow2"

images/fedora-34.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/34/Cloud/x86_64/images/Fedora-Cloud-Base-34-1.2.x86_64.qcow2"

images/fedora-35.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/35/Cloud/x86_64/images/Fedora-Cloud-Base-35-1.2.x86_64.qcow2"

images/fedora-36.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/36/Cloud/x86_64/images/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"