# NetBird Router

Unprivileged NixOS LXC on SERV1, untagged on `vmbr0` (Infra). It is the NetBird
routing peer for the home LANs; see `infra/netbird` for networks and policies.

## Bootstrap

1. Create the container from `lxc.conf` with the NixOS template
   (`nixos-system-proxmox-x86_64-linux.tar.xz`).
2. Encrypt the host's SSH key to age and add it to `nix-secrets/.sops.yaml`:
   `ssh-keyscan -t ed25519 netbird-router.internal.yomitosh.media | ssh-to-age`
3. Put the setup key from `nix run .#netbird -- output -raw router_setup_key`
   in `nix-secrets/hosts/netbird-router/default.enc.yaml` as `netbird/setupKey`.
4. Deploy:

```bash
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#netbird-router \
  --target-host root@netbird-router.internal.yomitosh.media \
  --build-host root@netbird-router.internal.yomitosh.media
```
