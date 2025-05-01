## 401

```conf
#nixos
arch: amd64
cmode: console
cores: 2
cpulimit: 2
features: mount=nfs,nesting=1
hostname: knode1
memory: 4096
nameserver: 10.0.1.53
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=BC:24:11:53:0C:FF,type=veth
net1: name=eth1,bridge=vmbr2,firewall=1,hwaddr=BC:24:11:36:A2:0D,type=veth
onboot: 1
ostype: unmanaged
rootfs: local-lvm:vm-401-disk-0,size=25G
startup: order=6
swap: 2048
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
lxc.mount.entry: /dev/net dev/net none bind,create=dir
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
```

## 402

```conf
<See 401 conf>
```

## 403

Should have GPU access

```conf
#nixos
arch: amd64
cmode: console
cores: 4
cpulimit: 6
features: mount=nfs,nesting=1
hostname: knode3
memory: 8192
nameserver: 10.0.1.53
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=62:49:F8:0F:F1:2A,type=veth
net1: name=eth1,bridge=vmbr2,firewall=1,hwaddr=6A:20:07:C3:E4:2A,type=veth
onboot: 1
ostype: unmanaged
rootfs: local-lvm:vm-403-disk-0,size=25G
startup: order=6
swap: 2048
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
lxc.mount.entry: /dev/net dev/net none bind,create=dir
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
```

## 499 (Template)

```conf
## NixOS LXC
#user%3A root
#pass%3A nixos
arch: amd64
cmode: console
features: nesting=1
hostname: knode
memory: 2048
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=BC:24:11:F1:08:3B,ip=dhcp,type=veth
# NOTE: Change these
# net0: name=eth0,bridge=vmbr0,firewall=1,gw=10.0.1.1,hwaddr=BC:24:11:F1:08:3B,ip=10.0.1.41/24,type=veth
# net1: name=eth1,bridge=vmbr2,firewall=1,hwaddr=BC:24:11:F1:08:3B,ip=10.0.7.41/24,type=veth
onboot: 1
ostype: unmanaged
rootfs: local-lvm:base-299-disk-0,size=10G
startup: order=6
swap: 2048
template: 1
unprivileged: 1
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
lxc.mount.entry: /dev/net dev/net none bind,create=dir
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=di
```
