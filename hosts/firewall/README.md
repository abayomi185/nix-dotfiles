# Firewall (NixOS router)

NixOS router running as Proxmox VM 506 on `pve-firewall`. The OPNsense
it replaced (VM 505) is stopped and kept as a rollback target — only one
runs at a time.

## Network map

| Segment            | Bridge / VLAN iface | Subnet         | Gateway     |
| ------------------ | ------------------- | -------------- | ----------- |
| WAN                | `wan0`              | DHCP           | —           |
| PHY LAN (untagged) | `br-phy`            | 10.1.1.0/24    | 10.1.1.1    |
| Infra (VLAN 5)     | `sfp1.5`            | 10.1.5.0/24    | 10.1.5.1    |
| Main (VLAN 10)     | `br-main`           | 10.1.10.0/24   | 10.1.10.1   |
| IoT (VLAN 50)      | `br-iot`            | 10.1.50.0/24   | 10.1.50.1   |
| WireGuard to VPS   | `wg0`               | 10.13.13.2/32  | 10.13.13.1  |

`br-main` and `br-iot` bridge VLAN 10 / 50 across both trunk NICs
(`sfp1` + `lan1`). The 6 virtio NICs are pinned to names by MAC via
systemd `.link` files (`net0→wan0 … net5→sfp1`).

Services: nftables (router firewall + WAN masquerade), Unbound (`:53`
recursive) + Dnsmasq (`:53053` local zone + DHCP), avahi mDNS reflector
(main↔infra↔iot), chrony NTP, qemu-guest-agent, SSH (key-only, from
`br-main` + `sfp1.5`).

The k3s cluster network (10.0.7.0/24) is a Proxmox-internal bridge the
firewall does not route; only static DNS records point at it.

## Deploy

From the admin Mac (builds Linux derivations on the router):

```bash
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#firewall \
  --target-host root@10.1.10.1 \
  --build-host root@10.1.10.1
```

When running directly on the router:

```bash
nixos-rebuild switch --flake .#firewall
```

## Rebuilding from scratch (disaster recovery)

The firewall decrypts sops secrets with its own `/root/.ssh/id_ed25519`
(generated to `~/firewall-root-key/id_ed25519` on the admin box, age
recipient `&firewall` in `.sops.yaml`). Stage it so nixos-anywhere drops
it in before first boot:

```bash
mkdir -p extra-files/root/.ssh
install -m 600 ~/firewall-root-key/id_ed25519     extra-files/root/.ssh/id_ed25519
install -m 644 ~/firewall-root-key/id_ed25519.pub extra-files/root/.ssh/id_ed25519.pub

nix run github:nix-community/nixos-anywhere -- \
  --flake .#firewall \
  --extra-files extra-files \
  --generate-hardware-config nixos-generate-config \
    ./hosts/firewall/hardware-configuration.nix \
  --target-host root@firewall.<internal-domain> \
  --build-host root@firewall.<internal-domain>

rm -rf extra-files
```

## Rollback to OPNsense

VM 505 is stopped but preserved. To fall back:

```bash
# On pve-firewall
sudo qm stop  506
sudo qm start 505
```

Only one router runs at a time — they share the same physical NIC plumbing.

## Operational notes

- **DHCP pools** are `.100–.250` per subnet. Static reservations are unchanged.
- **SSH** is allowed from Main and Infra (not just Main) to avoid lockout.
- **mDNS reflection**: Avahi reflects mDNS between Main, Infra, and IoT so
  Home Assistant can discover ESPHome devices across VLANs.
- **DNS split**: Unbound on `:53` forwards `internal.yomitosh.media` and
  reverse zones to Dnsmasq on `127.0.0.1:53053`, which auto-registers DHCP
  hostnames. `do-not-query-localhost = false` must be set in Unbound, otherwise
  the loopback forward is silently blocked.
- **Cluster DNS**: `knodeN.cluster.*` → 10.0.7.4x (cluster net); bare
  `knodeN.*` → 10.1.5.7x (mgmt, via DHCP reservation).
