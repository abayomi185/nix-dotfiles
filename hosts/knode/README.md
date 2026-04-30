# K-Node

Kubernetes cluster running on Proxmox KVM/QEMU VMs.

## Nodes

| VM ID | Hostname | Role              | CPUs | Memory | Notes          |
|-------|----------|-------------------|------|--------|----------------|
| 401   | knode1   | server (init)     | 2    | 4096   |                |
| 402   | knode2   | server            | 2    | 4096   |                |
| 403   | knode3   | server            | 4    | 8192   | GPU access     |

## Setup

1. Create a NixOS VM in Proxmox for each node.
2. Boot the NixOS installer and partition the disk with labels `boot` (vfat) and `nixos` (ext4).
3. Generate and commit the actual hardware configuration:
   ```bash
   nixos-generate-config --show-hardware-config
   ```
   Update `hardware-configuration.nix` with the generated output for each node.
4. Deploy with:
   ```bash
   nixos-rebuild switch --flake .#knode1
   ```
