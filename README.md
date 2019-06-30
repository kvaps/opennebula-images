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
alpine-3.10.qcow2       debian-9.qcow2          opensuse-leap-15.qcow2  
centos-6.qcow2          devuan-2.qcow2          ubuntu-16.04.qcow2      
centos-7.qcow2          fedora-30.qcow2         ubuntu-18.04.qcow2      
```

#### Generate appliance manifest for [OpenNebula Static Marketplace](https://github.com/kvaps/opennebula-static-marketplace):

```bash
./mkapp.static images/alpine-3.10.qcow2 "Alpine 3.10" alpine
```

will output:
```yaml
name: "Alpine 3.10"
logo: "/logos/alpine.png"
source: "https://example.org/images/alpine-3.10.qcow2"
import_id: "ac1bc98b-d824-4471-81ae-cc258507db71"
origin_id: "-1"
type: "IMAGE"
publisher: "Somebody"
format: "qcow2"
description: "Alpine 3.10 image for KVM hosts"
version: "5.8.0-1.20190627"
tags: "alpine"
regtime: "1561810835"
size: "500"
md5: "6b06b9f22f1c23cdf976835ba7cdc01d"
image_template: |
  DEV_PREFIX= "vd"
  DRIVER= "qcow2"
  TYPE= "OS"

vm_template: |
  CONTEXT = [ NETWORK  ="YES",SSH_PUBLIC_KEY  ="$USER[SSH_PUBLIC_KEY]"]
  
  CPU = "1"
  GRAPHICS = [ LISTEN  ="0.0.0.0",TYPE  ="vnc"]
  
  MEMORY = "128"
  OS = [ ARCH  ="x86_64"]
  
  LOGO = "images/logos/alpine.png"
```
