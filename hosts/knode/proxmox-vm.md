# Proxmox VM Configuration

## knode1 (VM 401)

```conf
arch: amd64
cores: 2
cpulimit: 2
memory: 4096
name: knode1
net0: virtio,bridge=vmbr0,firewall=1
net1: virtio,bridge=vmbr2,firewall=1
numa: 0
onboot: 1
ostype: l26
scsi0: local-lvm:vm-401-disk-0,size=25G
scsihw: virtio-scsi-pci
startup: order=6
```

## knode2 (VM 402)

```conf
arch: amd64
cores: 2
cpulimit: 2
memory: 4096
name: knode2
net0: virtio,bridge=vmbr0,firewall=1
net1: virtio,bridge=vmbr2,firewall=1
numa: 0
onboot: 1
ostype: l26
scsi0: local-lvm:vm-402-disk-0,size=25G
scsihw: virtio-scsi-pci
startup: order=6
```

## knode3 (VM 403)

Should have GPU passthrough.

```conf
arch: amd64
cores: 4
cpulimit: 6
memory: 8192
name: knode3
net0: virtio,bridge=vmbr0,firewall=1
net1: virtio,bridge=vmbr2,firewall=1
numa: 0
onboot: 1
ostype: l26
scsi0: local-lvm:vm-403-disk-0,size=25G
scsihw: virtio-scsi-pci
startup: order=6
```

