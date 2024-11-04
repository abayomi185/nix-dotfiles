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
nameserver: 10.0.1.53
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
