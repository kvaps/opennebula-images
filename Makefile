export LIBGUESTFS_BACKEND=direct
export LIBGUESTFS_MEMSIZE=10240

.PHONY: all clean

all: \
	images/alpine-3.16.qcow2 \
	images/alpine-3.17.qcow2 \
	images/alpine-3.18.qcow2 \
	images/ubuntu-20.04.qcow2 \
	images/ubuntu-22.04.qcow2 \
	images/ubuntu-23.10.qcow2 \
	images/debian-10.qcow2 \
	images/debian-11.qcow2 \
	images/debian-12.qcow2 \
	images/centos-7.qcow2 \
	images/centos-8-stream.qcow2 \
	images/centos-9-stream.qcow2 \
	images/fedora-38.qcow2 \
	images/fedora-39.qcow2 \

clean:
	rm -rf images/*

images/alpine-3.16.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.7-x86_64.tar.gz" \

images/alpine-3.17.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.17/releases/x86_64/alpine-minirootfs-3.17.5-x86_64.tar.gz" \

images/alpine-3.18.qcow2:
	./mkimage.alpine "$@" 500M \
		"https://alpine.global.ssl.fastly.net/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.4-x86_64.tar.gz" \

images/ubuntu-20.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img" \

images/ubuntu-22.04.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img" \

images/ubuntu-23.10.qcow2:
	./mkimage.ubuntu "$@" 2G \
		"https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64.img" \

images/debian-10.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2" \

images/debian-11.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2" \

images/debian-12.qcow2:
	./mkimage.debian "$@" 2G \
		"https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2" \

images/centos-7.qcow2:
	./mkimage.centos7 "$@" 2G \
		"https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c" \

images/centos-8-stream.qcow2:
	./mkimage.centos-stream "$@" 2G \
        "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2" \

images/centos-9-stream.qcow2:
	./mkimage.centos-stream "$@" 2G \
        "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow22" \

images/fedora-38.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"

images/fedora-39.qcow2:
	./mkimage.fedora "$@" 2G \
		"https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"