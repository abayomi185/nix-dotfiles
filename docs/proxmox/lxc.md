# Setting up NixOS LXC container

Reference: [mtlynch nixos-proxmox](https://mtlynch.io/notes/nixos-proxmox/)

Download image from [Hydra - proxmox lxc builds](https://hydra.nixos.org/job/nixos/release-24.05/nixos.proxmoxLXC.x86_64-linux) or [Hydra - lxd builds](https://hydra.nixos.org/job/nixos/release-24.05/nixos.lxdContainerImage.x86_64-linux)

```sh
# Where the template file is located
TEMPLATE_STORAGE='local'
# Name of the template file downloaded from Hydra.
TEMPLATE_FILE='nixos-system-proxmox-x86_64-linux.tar.xz'
# Name to assign to new NixOS container.
CONTAINER_HOSTNAME='nixos'
# Which storage location to place the new NixOS container.
CONTAINER_STORAGE='local-lvm'
# How much RAM to assign the new container.
CONTAINER_RAM_IN_MB='1024'
# How much disk space to assign the new container.
CONTAINER_DISK_SIZE_IN_GB='10'
```

```sh
sudo pct create 299 \
  --arch amd64 \
  "${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE_FILE}" \
  --ostype unmanaged \
  --description nixos \
  --hostname "${CONTAINER_HOSTNAME}" \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp,firewall=1 \
  --storage "${CONTAINER_STORAGE}" \
  --memory "${CONTAINER_RAM_IN_MB}" \
  --rootfs ${CONTAINER_STORAGE}:${CONTAINER_DISK_SIZE_IN_GB} \
  --unprivileged 1 \
  --features nesting=1 \
  --cmode console \
  --onboot 1 \
  --start 1
```

Default login should be `root` and no password. If it doesn't work, use `pct enter 299` to set a new password

```sh
source /etc/set-environment # Source default linux binaries
passwd # Change root password
```

```sh
nix-channel --update && \
  nixos-rebuild switch --upgrade && \
  echo "install complete, rebooting..." && \
  poweroff --reboot
```
