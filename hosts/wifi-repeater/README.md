# wifi-repeater

Raspberry Pi 4B / Pi 400 running NixOS as a wifi repeater.

```
INTERNET → main router → eth0 (DHCP, long cable) → Pi → wlan0 (AWUS0360ACS, 2.4 GHz AP) → Tesla
```

The Pi runs the Pi vendor kernel (`linuxPackages_rpi4`, 6.12 LTS) with the
out-of-tree **morrownr/8821au** driver for the AWUS0360ACS (RTL8811AU).
Single-radio, single-band: 2.4 GHz only. The AP broadcasts the same SSID
as your existing 2.4 GHz network (`Airport`) so devices — including the
Tesla — roam seamlessly between the main AP and the Pi's AP.

## Hardware

- Raspberry Pi 4B or Pi 400
- ALFA AWUS0360ACS (RTL8811AU, USB 2.0) — single radio, dual-band
  capable but broadcasts one band at a time
- SD card (16 GB+ recommended)
- Long Ethernet cable from the main router to the Pi

## Throughput expectations

- **Bottleneck**: AWUS0360ACS is USB 2.0 + 1×1 802.11ac. PHY rate
  150 Mbps on 2.4 GHz (HT40). Real-world TCP throughput **~80–100 Mbps**
  per the morrownr/USB-WiFi Performance Comparison and the MiniPCReviewer
  bench.
- **Not a bottleneck**: Pi 4 gigabit ethernet is ~940 Mbps; the SoC
  ethernet feeds the radio cleanly.
- For a Tesla in the basement: plenty for OTA software updates (100–500 MB
  transfers take 10–50 s at 80 Mbps) and 1080p streaming. 4K streaming
  would be marginal if anyone else is also using the AP.

If you need more bandwidth, the fix is a USB 3 + 2×2 adapter (e.g. an
AWUS036ACH with the mt7612u chipset — in-kernel, no out-of-tree drama),
not a different Pi.

## One-time setup: SOPS passphrase

The hostapd WPA2 passphrase is encrypted at rest in
`hosts/wifi-repeater/secrets.enc.yaml` and decrypted at activation by
sops-nix using your SSH key.

1. Replace the placeholder in `hosts/wifi-repeater/secrets.enc.yaml`:

   ```yaml
   hostapd_passphrase: YourStrongPassphrase
   ```

2. Encrypt it in place with sops (same age recipient as the rest of
   your nix-secrets):

   ```bash
   sops --encrypt --in-place --age <your-age-recipient> \
     hosts/wifi-repeater/secrets.enc.yaml
   ```

3. (Optional) Move the encrypted file to your `nix-secrets` repo and
   update `sops.defaultSopsFile` in `configuration.nix` to point there
   (matches the knode pattern). Keep the local file empty / gitignored
   if you do.

## Set the SSID

The default SSID is `Airport` to match your existing 2.4 GHz network, so
the Tesla and other devices roam seamlessly. To change, edit
`hosts/wifi-repeater/configuration.nix` and search for `ssid = "Airport"`.
**Channel**: `channel = 0` enables **ACS** (Automatic Channel Selection).
Hostapd scans all 2.4 GHz channels at every boot and picks the cleanest.
No thinking required.

If you'd rather pin a channel, set it to 1, 6, or 11 (UK non-overlapping
2.4 GHz channels) — pick one **different from your main AP**:

```nix
services.hostapd.radios.wlan0.channel = 6;  # or 1, 11, etc.
```

## Pre-create SSH keys (host-specific, outside the repo)

The default config authorizes the keys in
`inputs.nix-secrets/shared/authorized-keys.nix` (your personal key,
same as the knode hosts). For a tighter, host-specific key:

1. Generate a key outside the repo (the private key never lives in git):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/wifi-repeater \
     -C "wifi-repeater@$(hostname -s)"
   ```

2. Add the **public** key to the image. Create
   `hosts/wifi-repeater/authorized-keys.nix`:

   ```nix
   [
     # Paste contents of ~/.ssh/wifi-repeater.pub here:
     "ssh-ed25519 AAAA... wifi-repeater@yourhost"
   ]
   ```

3. In `configuration.nix`, swap the import:

   ```nix
   users.users.root.openssh.authorizedKeys.keys =
     import ./authorized-keys.nix;
   ```

4. After flashing, connect using the private key (which never leaves
   your laptop):

   ```bash
   ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local
   ```

5. For SOPS to work on the Pi, the private key (or the age key the
   secrets file was encrypted for) must also be at
   `/root/.ssh/id_ed25519` on the Pi. The simplest way is to use the
   **same key** for SSH login AND SOPS:

   ```bash
   ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local \
     "install -d -m 700 /root/.ssh"
   scp -i ~/.ssh/wifi-repeater ~/.ssh/wifi-repeater \
     root@wifi-repeater.local:/root/.ssh/id_ed25519
   ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local \
     "chmod 600 /root/.ssh/id_ed25519 && nixos-rebuild switch"
   ```

   Alternative: keep using your personal SSH key for SOPS (knode
   pattern) and the host-specific key only for login. Both pub keys go
   in `authorized-keys.nix`; the personal private key is what you copy
   to `/root/.ssh/id_ed25519`.

## Build the SD image

The target is aarch64-linux; your build host is x86_64 Linux (`machine-learning`).
This is a cross-compile via QEMU user-mode emulation, which is ~10× slower
than native. **First build = 12+ hours** (the Pi 4 vendor kernel is no
longer in the NixOS binary cache as of 26.05 — see [Discourse thread][rpi4-cache]).
Subsequent rebuilds are incremental.

[rpi4-cache]: https://discourse.nixos.org/t/nixos-26-05-raspberry-pi-4-kernel-cache-missing/78125

### 1. Register QEMU aarch64 on the Proxmox HOST

`machine-learning` is an **unprivileged LXC container**; it shares the
host kernel but cannot register binfmt formats itself. The host must do
it.

**If the Proxmox host runs NixOS** (e.g. `firewall` in this repo),
add to its NixOS config:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

Then `nixos-rebuild switch` on the host. Done.

**If the Proxmox host runs Debian/Ubuntu** (the default Proxmox install):

```bash
apt install -y qemu-user-static binfmt-support
update-binfmts --enable qemu-aarch64
ls /proc/sys/fs/binfmt_misc/qemu-aarch64   # should print "enabled"
```

### 2. Tell Nix on `machine-learning` about aarch64

`machine-learning` is Ubuntu with standalone nix. Add aarch64 to the
substitutable platforms:

```bash
# System-wide (if you can sudo):
echo 'extra-platforms = aarch64-linux' | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon

# Or per-user:
mkdir -p ~/.config/nix
echo 'extra-platforms = aarch64-linux' >> ~/.config/nix/nix.conf
```

Verify the LXC container can reach the host's binfmt:

```bash
# On machine-learning:
ls /proc/sys/fs/binfmt_misc/qemu-aarch64   # should be visible
file $(command -v uname)                   # ELF 64-bit LSB executable, ARM aarch64
```

(If `/proc/sys/fs/binfmt_misc/` isn't visible inside the container,
add `lxc.mount.entry = proc proc proc nodev,noexec,nosuid 0 0` to the
container's LXC config on the host and restart it.)

### 3. Build

```bash
# From the repo on machine-learning
nix build .#wifi-repeater.config.system.build.sdImage
```

If `extra-platforms` isn't in nix.conf yet, pass it inline:

```bash
nix build .#wifi-repeater.config.system.build.sdImage \
  --extra-experimental-features 'nix-command flakes' \
  --option extra-platforms 'aarch64-linux'
```

The image is written to `result/sd-image/nixos-image-rpi4-uboot.img`
(uncompressed, ~2 GB, directly flashable). The build evaluates a
derivation even if the SOPS file is unencrypted, but flashing without
encrypting the secrets file means the activation can't decrypt the
passphrase and hostapd won't start. Encrypt first.

### 4. Speed it up: remote aarch64 builder

QEMU emulation is OK for the first build but painful for iteration. Add
a native aarch64 remote builder — the **Pi itself** is the obvious one
once it's flashed. From your build-host nix config (e.g. the shared
`machine-learning` settings, or a global `~/.config/nix/nix.conf`):

```nix
nix.buildMachines = [{
  hostName = "wifi-repeater.local";
  sshUser = "root";
  systems = [ "aarch64-linux" ];
  maxJobs = 4;            # Pi 4 has 4 cores
  speedFactor = 4;        # native aarch64 is ~4× faster than QEMU
  supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
}];
nix.distributedBuilds = true;
```

`nix build` will then route aarch64-linux derivations to the Pi over
SSH and only fall back to local QEMU if the Pi is unreachable. Kernel
rebuilds drop from 12+ hours to ~20 minutes.

## Flash the SD card

The output is a raw `.img` file — Raspberry Pi Imager and balenaEtcher
both accept it directly.

### Raspberry Pi Imager

1. Open Raspberry Pi Imager.
2. **Choose OS** → scroll to bottom → **Use Custom**.
3. Select `result/sd-image/nixos-image-rpi4-uboot.img`.
4. **Choose Storage** → your SD card.
5. **Write**. No OS-customisation needed (everything is in the image).

### balenaEtcher

1. Open balenaEtcher.
2. **Flash from file** → select the `.img`.
3. **Select target** → your SD card.
4. **Flash!**

### `dd` (manual)

```bash
# macOS — replace /dev/rdisk4 with the actual SD device
sudo dd if=result/sd-image/nixos-image-rpi4-uboot.img \
   of=/dev/rdisk4 bs=4M status=progress conv=fsync
sync

# Linux — replace /dev/mmcblk0
sudo dd if=result/sd-image/nixos-image-rpi4-uboot.img \
   of=/dev/mmcblk0 bs=4M status=progress conv=fsync
sync
```

Partition table is auto-expanded on first boot.

## First boot

1. Plug the AWUS0360ACS into a Pi 4 USB 2.0 port (the **black** ones,
   not blue — AWUS0360ACS is USB 2 and the USB 3 ports can have
   interference).
2. Plug Ethernet from the main router.
3. Power on the Pi. The first boot resizes the root partition and
   reboots.
4. Find the Pi on the network:
   - macOS: `dns-sd -G v4 wifi-repeater.local`
   - Linux: `avahi-resolve -n wifi-repeater.local`
   - Or check your router's DHCP lease table (hostname `wifi-repeater`).
5. SSH in as root with the private key you generated earlier:

   ```bash
   ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local
   ```

## Unlock SOPS (post-flash)

The first activation can't decrypt the passphrase because the SOPS key
isn't on the Pi yet:

```bash
# Copy the private SSH key the secrets file was encrypted for.
# If you used a Pi-specific key (see "Pre-create SSH keys" above),
# this is the same key.
ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local \
  "install -d -m 700 /root/.ssh"
scp -i ~/.ssh/wifi-repeater ~/.ssh/wifi-repeater \
  root@wifi-repeater.local:/root/.ssh/id_ed25519
ssh -i ~/.ssh/wifi-repeater root@wifi-repeater.local \
  "chmod 600 /root/.ssh/id_ed25519 && nixos-rebuild switch"
```

After this, hostapd starts (you may also `systemctl restart hostapd`).

## Remote rebuilds

```bash
# From macOS, using the host-specific key
nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#wifi-repeater \
  --target-host root@wifi-repeater.local \
  --build-host root@wifi-repeater.local

# From a Linux host
sudo nixos-rebuild switch \
  --flake .#wifi-repeater \
  --target-host root@wifi-repeater.local
```

(The `--build-host` lets the Pi itself do the kernel compile on remote
rebuilds — useful since the rpi4 kernel isn't in the public cache.)

## Verify

```bash
ssh root@wifi-repeater.local "lsmod | grep 8821au"        # driver loaded?
ssh root@wifi-repeater.local "iw dev wlan0 info"          # AP up?
ssh root@wifi-repeater.local "systemctl status hostapd"   # service running?
ssh root@wifi-repeater.local "journalctl -u hostapd -n 50" # any errors?
ssh root@wifi-repeater.local "iperf3 -s"                  # then iperf3 from a client
```

## Dual band (not implemented)

The AWUS0360ACS has one radio; it broadcasts one band at a time. This
config is 2.4 GHz only, the right choice for a basement-to-Tesla link
(range over speed). If you want 5 GHz too, you need a second adapter
(morrownr's [USB-WiFi Plug and Play List][plug] has recommendations).
Adding it would mean a second `radios.wlan1` block + a second
dnsmasq range — open an issue/PR if you want to spec it.

[plug]: https://github.com/morrownr/USB-WiFi/blob/main/home/USB_WiFi_Adapters_that_are_supported_with_Linux_in-kernel_drivers.md

## Known limitations

- **First build time**: rpi4 vendor kernel cache missing in 26.05
  (see [Discourse thread][rpi4-cache]). First build = 12+ hours of
  kernel compilation. Subsequent builds are fast.

- **Kernel/driver coupling**: `pkgs.rtl8821au` is `broken` on kernels
  ≥ 6.15. The in-kernel `rtw_8821au` driver covers RTL8811AU from
  6.14 onwards, but is less battle-tested for AP mode. If the rpi4
  vendor kernel crosses 6.15, switch to `boot.kernelModules = [ "rtw_8821au" ]`
  and remove the out-of-tree driver.

- **Power budget**: Pi 4 USB subsystem shares 1200 mA across all ports.
  AWUS0360ACS peaks at ~500 mA. Don't plug in anything else on USB.

- **Single radio**: no simultaneous 2.4 + 5 GHz from one adapter. See
  "Dual band" above.

- **Regulatory**: 5 GHz DFS channels are not used. `countryCode = "GB"`
  is baked in. If you move the Pi, change `services.hostapd.radios.wlan0.countryCode`.

- **Network Manager conflict**: if you ever add NetworkManager, it will
  fight hostapd for control of wlan0. Add to its config:
  `[keyfile] unmanaged-devices=interface-name:wlan0`
