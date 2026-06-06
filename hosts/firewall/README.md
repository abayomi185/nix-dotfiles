# Firewall (NixOS router)

NixOS replacement for the OPNsense router, migrated 1:1 from the OPNsense
config export. Runs as a Proxmox VM alongside the existing OPNsense VM (guest
**505**), which stays in place as a rollback target — only one of the two runs
at a time (they share the same physical NIC plumbing).

## Network map

| Segment            | Bridge / VLAN iface | Subnet         | Gateway     | OPNsense   |
| ------------------ | ------------------- | -------------- | ----------- | ---------- |
| WAN                | `wan0` (vtnet0)     | DHCP           | —           | wan        |
| PHY LAN (untagged) | `br-phy`            | 10.1.1.0/24    | 10.1.1.1    | opt2/bridge0 |
| Infra (VLAN 5)     | `sfp1.5`            | 10.1.5.0/24    | 10.1.5.1    | opt13/vlan04 |
| Main (VLAN 10)     | `br-main`           | 10.1.10.0/24   | 10.1.10.1   | opt11/bridge1 |
| IoT (VLAN 50)      | `br-iot`            | 10.1.50.0/24   | 10.1.50.1   | opt12/bridge2 |
| WireGuard to VPS   | `wg0`               | 10.13.13.2/32  | 10.13.13.1  | opt14/WG0  |

`br-main` / `br-iot` bridge VLAN 10 / 50 across **both** trunk NICs (`sfp1` +
`lan1`), matching OPNsense. The 6 virtio NICs are pinned to names by MAC via
systemd `.link` files (`net0→wan0 … net5→sfp1`).

Services: nftables (router firewall + WAN masquerade), Unbound (`:53` recursive)
+ Dnsmasq (`:53053` local zone + DHCP), avahi mDNS reflector (main↔infra),
chrony NTP, qemu-guest-agent, SSH (key-only, from `br-main` + `sfp1.5`).

The k8s cluster network (10.0.7.0/24) is a Proxmox-internal bridge the firewall
does not route; only static DNS records point at it.

## Before switchover — fill in the placeholders

1. **Create the VM in Proxmox** (a *new* guest id, e.g. 506; leave 505 alone):
   - Firmware **OVMF (UEFI)**, machine q35; disk on a **VirtIO SCSI** controller
     (→ `/dev/sda`, see `disko-config.nix`).
   - **6 virtio NICs `net0..net5`** wired to the *same* Proxmox bridges / VLAN
     tags as OPNsense VM 505. Dump 505's NIC layout to mirror it exactly:
     ```bash
     ssh yom@pve-firewall.internal.yomitosh.media -- sudo qm config 505
     ```
     (`net0`=WAN … `net5`=SFP trunk, in the same order as the table above.)

2. **Pin the MAC addresses.** Set a known MAC on each NIC in the Proxmox VM
   config, then copy them into the `macs = { … }` block in `networking.nix`
   (replace the `XX:XX:…` placeholders). Until this is done the router will not
   come up (NIC naming fails loudly rather than mis-ordering).

3. **Create the WireGuard secret** in the `nix-secrets` repo. Reuse the existing
   OPNsense WG0 private key so the VPS peer needs no change:
   ```bash
   # in the nix-secrets checkout, encrypted to the shared age recipient
   sops hosts/firewall/default.enc.yaml
   # add:
   #   wireguard:
   #     privateKey: QLmtOUOW6CMWSs4yjMzGH3ND4PEIrQ/xR6SyoMurOm4=
   ```
   (The matching public key `CvwrIcJkTMA+w44xOIsvGXH2dH4gQCywLnVQZrx2DlI=` is
   already a trusted peer on the VPS.) Commit + push nix-secrets, then
   `nix flake update nix-secrets` here.

## Install

`nixos-anywhere` onto the booted NixOS installer ISO (disko partitions the
disk, hardware config is generated):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#firewall \
  --generate-hardware-config nixos-generate-config \
    ./hosts/firewall/hardware-configuration.nix \
  --target-host root@<installer-ip>
```

SOPS decrypts with `/root/.ssh/id_ed25519` (same shared key as the knodes), so
copy it to the box before activation completes:

```bash
ssh root@<firewall-ip> "install -d -m 700 /root/.ssh"
rsync -avP id_ed25519 id_ed25519.pub root@<firewall-ip>:/root/.ssh/
ssh root@<firewall-ip> "chmod 600 /root/.ssh/id_ed25519 && /run/current-system/bin/switch-to-configuration switch"
```

Subsequent changes:

```bash
nixos-rebuild switch --flake .#firewall --target-host root@firewall.internal.yomitosh.media
```

## Cutover & rollback

Only one router runs at a time:

```bash
# cut over to NixOS
sudo qm shutdown 505            # stop OPNsense
sudo qm start    506            # start NixOS firewall

# roll back if something is wrong
sudo qm stop  506               # stop NixOS
sudo qm start 505               # bring OPNsense back
```

## Verify after cutover

- `nft list ruleset` loads; `dhcp-leases` shows clients getting addresses.
- DNS: `dig @10.1.10.1 knode1.internal.yomitosh.media` → 10.1.5.71;
  `dig @10.1.10.1 anything.local.yomitosh.media` → 10.1.5.40; external names resolve.
- WireGuard: `wg show` shows a recent handshake with the VPS.
- Routing: a Main-LAN client reaches the internet; an IoT client reaches the
  internet but **not** 10.1.10.0/24 or 10.1.5.0/24.

## Deltas from OPNsense (intentional)

- DHCP pools narrowed to `.100–.250` per subnet (OPNsense ranged `.1–.255`,
  overlapping the gateway). Static reservations are unchanged.
- SSH allowed from Main **and** Infra (OPNsense: Main only) to avoid lockout.
- `knodeN.cluster.*` → 10.0.7.4x (cluster net); bare `knodeN.*` → 10.1.5.7x
  (mgmt, via DHCP reservation). OPNsense pointed both at the mgmt IPs.
