# K-Node

Kubernetes cluster runs in Proxmox VMs.

Current roles:
- `knode1`: k3s server
- `knode2`: k3s agent
- `knode3`: k3s agent
- `knode4`: k3s agent

Initial install is done with `nixos-anywhere`.

SOPS decrypts `k3s_token` with `/root/.ssh/id_ed25519`, so you must copy the
shared private key to the node before re-running activation.

```bash
export NODE_NUM=1 # Replace with the node number you want to update (1, 2, 3, 4)
ssh root@knode${NODE_NUM}.internal.yomitosh.media "install -d -m 700 /root/.ssh"
rsync -avP id_ed25519 id_ed25519.pub root@knode${NODE_NUM}.internal.yomitosh.media:/root/.ssh/
ssh root@knode${NODE_NUM}.internal.yomitosh.media "chmod 600 /root/.ssh/id_ed25519 && chmod 644 /root/.ssh/id_ed25519.pub && /run/current-system/bin/switch-to-configuration switch"
```

To apply configuration changes from this repo:

```bash
export NODE_NUM=1 # Replace with the node number you want to update (1, 2, 3, 4)
sudo nixos-rebuild switch \
  --flake .#knode${NODE_NUM} \
  --target-host root@knode${NODE_NUM}.internal.yomitosh.media
```

To run from macOS:

```sh
export NODE_NUM=1 # Replace with the node number you want to update (1, 2, 3, 4)
nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#knode${NODE_NUM} \
  --target-host root@knode${NODE_NUM}.internal.yomitosh.media
```
