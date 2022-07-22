# OpenNebula Images Generator

Generate your own OpenNebula Images automactically

### Preparation

Install `make` and `libguestfs-tools` packages, or use docker:

```bash
docker build -t guestfish .
docker run -ti --rm -v $PWD:/build guestfish
```

### Usage

Just use `make`, example:

```bash
make images/<tab>
```

will suggest:

```
images/alpine-3.13.qcow2      images/alpine-3.16.qcow2      images/centos-8.qcow2         images/debian-11.qcow2        images/fedora-35.qcow2        images/ubuntu-20.04.qcow2                                 
images/alpine-3.14.qcow2      images/centos-7.qcow2         images/centos-9-stream.qcow2  images/debian-9.qcow2         images/fedora-36.qcow2        images/ubuntu-22.04.qcow2                                 
images/alpine-3.15.qcow2      images/centos-8-stream.qcow2  images/debian-10.qcow2        images/fedora-34.qcow2        images/ubuntu-18.04.qcow2                                                             ```

#### Generate appliance manifest for [OpenNebula Static Marketplace](https://github.com/kvaps/opennebula-static-marketplace):

```bash
./mkapp.static images/alpine-3.13.qcow2 "Alpine 3.13" alpine
```

will output:
```yaml
name: "Alpine 3.13"
logo: "/logos/alpine.png"
source: "https://example.org/images/alpine-3.13.qcow2"
import_id: "0135E439-D1D3-4BE6-8FA2-E68C30E0D92C"
origin_id: "-1"
type: "IMAGE"
publisher: "Somebody"
format: "qcow2"
description: "Alpine 3.13 image for KVM hosts"
version: "5.8.0-1.20190627"
tags: "alpine"
regtime: "1561810835"
size: "500"
md5: "9de7e0b579b11c4a6978239fce252252"
image_template: |
  DEV_PREFIX= "vd"
  DRIVER= "qcow2"
  TYPE= "OS"

vm_template: |
  CONTEXT = [ NETWORK  ="YES",SSH_PUBLIC_KEY  ="$USER[SSH_PUBLIC_KEY]"]

  CPU = "1"
  GRAPHICS = [ LISTEN  ="0.0.0.0",TYPE  ="vnc"]

  MEMORY = "512"
  OS = [ ARCH  ="x86_64"]

  LOGO = "images/logos/alpine.png"
```
