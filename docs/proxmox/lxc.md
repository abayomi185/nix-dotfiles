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

The container is unmanaged so Proxmox won't be able to set up the network and this will need to be done manually once before the nix config comes into effect:

```sh
ip addr add 10.0.1.41/24 dev eth0
ip link set eth0 up
ip route add default via 10.0.1.1
# If DNS is not resolving, add the following
# echo "nameserver 8.8.8.8" >> /etc/resolv.conf
# echo "nameserver 8.8.4.4" >> /etc/resolv.conf
```

Get minimal configuration from the repo and set up nix channels

```sh
curl \
  --show-error \
  --fail \
  https://raw.githubusercontent.com/abayomi185/nix-dotfiles/refs/heads/main/hosts/knode/minimal-configuration.nix \
  > /etc/nixos/configuration.nix
```

```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update
```

After Nix channels are set up, the system can be switched.

```sh
nixos-rebuild switch --upgrade
```

```sh
nix-shell -p git ssh-to-age
git clone https://github.com/abayomi185/nix-dotfiles.git
cd nix-dotfiles
nixos-rebuild switch --flake .#knode<id> # not needed if hostname is knode<id>
```

```sh
pct push 40<nodeId> /boot/config-$(uname -r) /boot/config-$(uname -r)
```

```sh
#!/bin/sh -e
if [ ! -e /dev/kmsg ]; then
	ln -s /dev/console /dev/kmsg
fi
mount --make-rshared /
```
