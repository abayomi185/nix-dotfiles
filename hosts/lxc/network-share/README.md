# Network Share

LXC container for sharing files over the network using Samba, NFS and FTP.

This powers:

- Time Machine backups
- Sony camera wireless transfers via FTP
- Powers NFS backbone for kubernetes

```bash
   nix run nixpkgs#nixos-rebuild -- switch \
     --flake .#network-share \
     --build-host root@network-share.internal.yomitosh.media \
     --target-host root@network-share.internal.yomitosh.media
     # --use-remote-sudo
```
