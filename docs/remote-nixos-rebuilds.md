# Remote NixOS rebuilds from macOS

When rebuilding an `x86_64-linux` NixOS host from an Apple Silicon Mac, build on
the Linux target instead of trying to build Linux derivations on Darwin:

```sh
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#<hostname> \
  --target-host root@<hostname-or-ip> \
  --build-host root@<hostname-or-ip>
```

`--build-host` makes the target machine build the system closure. Private flake
inputs such as `nix-secrets` are fetched/evaluated by the local machine and
copied to the remote builder as encrypted store sources; the remote host does
not need GitHub access for those inputs in this workflow.

SOPS plaintext is not decrypted locally or copied over. `sops-nix` decrypts on
the target during activation using that host's configured age identity, e.g.
`/etc/ssh/ssh_host_ed25519_key`.
