# wifi-repeater

Raspberry Pi 4B / Pi 400 running NixOS as a 2.4 GHz wireless
repeater. eth0 (DHCP from the main router) bridges to wlan0
(AWUS0360ACS in AP mode) via NAT masquerade, with dnsmasq
serving DHCP on the AP subnet.

## Hardware

- Raspberry Pi 4B or Pi 400
- ALFA AWUS0360ACS (RTL8811AU, USB 2.0) — single radio
- SD card 16 GB+
- Ethernet cable from the main router

The adapter has one radio, so only one band is broadcast at a
time. 2.4 GHz only here.

## Throughput

AWUS0360ACS is USB 2.0 + 1×1 802.11ac. PHY 150 Mbps on 2.4 GHz;
real TCP ~80–100 Mbps. The Pi 4's gigabit ethernet is ~940 Mbps,
so the radio is the bottleneck. The Pi 4 USB subsystem shares
1200 mA; the adapter peaks at ~500 mA, so nothing else on USB.

## Driver

In-kernel `rtw_8821au` (mainline from 6.13, polished in 6.14)
covers the RTL8811AU (`0bda:0811`). The out-of-tree
morrownr/8821au-20210708 driver is broken on kernels ≥ 6.15 and
morrownr has deprecated it, so we use the in-kernel driver.

AP mode on `rtw_8821au` has open flakiness reports
([lwfinger/rtw88#323][flaky-ap]); test the AP on the bench
before deploying.

## Configuration knobs

`hosts/wifi-repeater/configuration.nix`:

- **`ssid`** in `services.hostapd.radios.wlan0.networks.wlan0` —
  broadcast SSID. Default `"Airport"`.
- **`channel`** — `0` enables ACS (auto-pick at boot). Pin to 1, 6,
  or 11 (UK non-overlapping 2.4 GHz); must differ from the main AP.
- **`countryCode`** — `"GB"` is baked in. Change if the Pi moves.
- **AP subnet** — `192.168.50.0/24`, gateway `.1`. Adjust in
  `networking.interfaces.wlan0.ipv4.addresses` and the dnsmasq
  `dhcp-range` to change.
- **WPA2 passphrase** — set in `secrets.enc.yaml` (see below).

## Build

Target is aarch64-linux; the build host in this repo is x86_64
(`machine-learning`). This is a cross-compile via QEMU user-mode
emulation. **First build = 12+ hours** (rpi4 vendor kernel is no
longer in the NixOS binary cache as of 26.05). Subsequent
rebuilds are incremental.

### Proxmox host setup

`machine-learning` is an unprivileged LXC container; it shares
the host kernel but can't register binfmt formats itself.

**NixOS host:**

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

**Debian/Ubuntu host:**

```bash
apt install -y qemu-user-static binfmt-support
update-binfmts --enable qemu-aarch64
```

### Nix on machine-learning

For repeated builds, add aarch64 to the nix config so you don't
need a flag every time:

```bash
echo 'extra-platforms = aarch64-linux' | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```


For a one-off build without changing nix.conf, pass the flag
directly (see the build command below).

### Build command

```bash
# With the nix.conf setting above, just:
nix build .#wifi-repeater.config.system.build.sdImage

# Or one-off, without touching nix.conf:
nix build .#wifi-repeater.config.system.build.sdImage \
  --extra-platforms aarch64-linux
```

Image is written to `result/sd-image/nixos-image-rpi4-uboot.img`
(uncompressed, ~2 GB).
```nix
nix.buildMachines = [{
  hostName = "wifi-repeater.local";
  sshUser = "root";
  systems = [ "aarch64-linux" ];
  maxJobs = 4;
  speedFactor = 4;
}];
nix.distributedBuilds = true;
```

Kernel rebuilds drop from 12+ hours to ~20 minutes.

## Pre-flash: passphrase and SSH keys

Set the WPA2 passphrase in `hosts/wifi-repeater/secrets.enc.yaml`
and encrypt it in place:

```bash
# Edit the file:
hostapd_passphrase: YourStrongPassphrase

# Encrypt:
sops --encrypt --in-place --age <your-age-recipient> \
  hosts/wifi-repeater/secrets.enc.yaml
```

The build evaluates a derivation even if the file is unencrypted,
but the activation can't decrypt and hostapd won't start.

For SSH keys, the default config authorizes the keys in
`inputs.nix-secrets/shared/authorized-keys.nix` (your personal
key, same as the knode hosts). For a host-specific key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/wifi-repeater \
  -C "wifi-repeater@$(hostname -s)"
```

Create `hosts/wifi-repeater/authorized-keys.nix` with the public
key, then in `configuration.nix`:

```nix
users.users.root.openssh.authorizedKeys.keys =
  import ./authorized-keys.nix;
```

## Flash

The output is a raw `.img`. Both Raspberry Pi Imager and
balenaEtcher accept it directly.

- **Raspberry Pi Imager**: Choose OS → Use Custom → select the
  `.img`.
- **balenaEtcher**: Flash from file → select the `.img` → select
  target.
- **`dd`** (manual): `sudo dd if=result/sd-image/nixos-image-rpi4-uboot.img of=/dev/mmcblk0 bs=4M status=progress conv=fsync`
  (Linux) or `of=/dev/rdisk4` (macOS).

Partition table is auto-expanded on first boot.

## First boot

1. Plug the adapter into a Pi 4 USB 2.0 port (black, not blue).
2. Plug Ethernet from the main router.
3. Power on. The first boot resizes the root partition and
   reboots.
4. Find the Pi: `avahi-resolve -n wifi-repeater.local` (Linux) or
   `dns-sd -G v4 wifi-repeater.local` (macOS), or check the
   router's DHCP lease table.
5. SSH in:

   ```bash
   ssh root@wifi-repeater.local
   ```

## Unlock SOPS (post-flash)

The first activation can't decrypt the passphrase because the
SOPS key isn't on the Pi yet. Copy the private key the secrets
file was encrypted for:

```bash
ssh root@wifi-repeater.local "install -d -m 700 /root/.ssh"
scp ~/.ssh/<key> root@wifi-repeater.local:/root/.ssh/id_ed25519
ssh root@wifi-repeater.local \
  "chmod 600 /root/.ssh/id_ed25519 && nixos-rebuild switch"
```

## Remote rebuilds

```bash
sudo nixos-rebuild switch \
  --flake .#wifi-repeater \
  --target-host root@wifi-repeater.local
```

## Verify

```bash
ssh root@wifi-repeater.local "lsmod | grep 8821au"
ssh root@wifi-repeater.local "iw dev wlan0 info"
ssh root@wifi-repeater.local "systemctl status hostapd"
```

## Known limitations

- **AP mode on in-kernel `rtw_8821au`**: less battle-tested than the
  out-of-tree morrownr driver. Verify on the bench before deploying;
  see [lwfinger/rtw88#323][flaky-ap].
- **First build time**: 12+ hours for the kernel compile on a fresh
  26.05 host.
- **Single radio**: 2.4 GHz only. For 5 GHz, a second adapter is
  needed.

[flaky-ap]: https://github.com/lwfinger/rtw88/issues/323
