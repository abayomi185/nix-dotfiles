# Builder

Nix remote builder VM (pve VMID 303) for `x86_64-linux` and emulated
`aarch64-linux`. It takes over the build role of the `machine-learning` LXC.

Install with `nixos-anywhere` from the NixOS installer ISO:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#builder \
  --target-host root@<installer-ip>
```

Apply changes:

```sh
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#builder \
  --target-host root@builder.internal.yomitosh.media \
  --build-host root@builder.internal.yomitosh.media
```

Build on it from a Mac. The Nix daemon connects as root, so root's SSH key on
the Mac must be authorised here:

```sh
nix build .#nixosConfigurations.wifi-repeater.config.system.build.sdImage \
  --builders 'ssh-ng://root@builder.internal.yomitosh.media x86_64-linux,aarch64-linux'
```
