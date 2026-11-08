# Video recorder

NixOS VM for `pve` on [YHLD-SERV1](https://github.com/abayomi185/homelab/blob/main/devices/YHLD-SERV1/YHLD-SERV1.md).
MediaMTX receives two camera streams and records them independently without
transcoding. No GPU, desktop session, OBS instance, or capture card is needed.

```text
Sony a7V  ── Wi-Fi / Ethernet ──┐
                              ├── video-recorder VM ── NFS (network-share)
Sony a7CR ── Wi-Fi / Ethernet ─┘        │
                                 browser preview
```

The low-friction workflow is to power the camera, enter network streaming,
and start streaming. Recording starts when the server receives media and ends
when the stream stops. The camera's ordinary movie record button is not assumed
to start network streaming. Each reconnect creates new files. The two cameras
have separate clocks and are not frame synchronized; use a clap and camera audio
for multicamera alignment in editing.

## Camera requirements

Sony documents network streaming for both cameras. The a7CR requires firmware
**2.00 or later**. Configure the destination in Sony Creators' App, then start
from the camera's Network > Streaming > Network Streaming menu or the app.

- [a7V network streaming](https://helpguide.sony.net/ilc/2540/v1/en/contents/221h_network_streaming.html)
- [a7CR network streaming and firmware requirement](https://helpguide.sony.net/ilc/2370/v1/en/contents/221h_network_streaming.html)

Start with H.265 over SRT on the trusted main LAN, at 1440p 25p or 30p around
8 Mbps. Use 1080p 25p at 6 Mbps for the first connectivity check. Sony supports wired
and wireless networking; compatible USB Ethernet adapters are an option if
Wi-Fi proves unreliable. Verify long-duration power and temperature behaviour
with the actual cameras. Keep card recording enabled during initial trials.

At 8 Mbps, allow roughly 3.6 GB per camera-hour plus audio and container
overhead, or about 7 GB/hour for both cameras. These are compressed streaming
files, not an assurance of the same quality, bit depth, or colour sampling as
in-camera masters. For work needing those masters, keep card recording too.

## VM provisioning

Nothing is provisioned yet. Pick a free VMID on `pve` and record it, with the
DHCP address and MAC, in the homelab inventory once created.

Create a UEFI VM like `sonamesh`: 2 vCPU, 2 GiB RAM, 16 GiB `local-lvm` SCSI
disk, one virtio NIC on `vmbr0`, booted from the repo `livecd` ISO.

```sh
qm create <VMID> --name video-recorder --onboot 1 --ostype l26 \
  --machine q35 --bios ovmf --efidisk0 local-lvm:0,efitype=4m \
  --cores 2 --memory 2048 --agent 1 \
  --scsihw virtio-scsi-single --scsi0 local-lvm:16,iothread=1,ssd=1 \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --ide2 local:iso/livecd.iso,media=cdrom --boot 'order=scsi0;ide2'
```

`livecd` takes root SSH with the shared authorized keys, so install straight from
this repository. The disk layout is the shared `hosts/nixos-anywhere/disk-config.nix`.

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#video-recorder --build-on remote root@<ISO_IP>
```

Recordings go to `/mnt/mofp0/data/NAS-YOM/VideoProjects`, NFS-mounted from
`network-share` (existing `NAS-YOM` export, `10.1.5.0/24`, `no_root_squash`) at
`/srv/recordings`. Only that directory is mounted. Footage lives on the NAS, not
the VM disk, so cover it with the NAS backup policy.

The service runs as UID 1001, GID 100, the same identity as `sambayom` in
`network-share`. MediaMTX creates directories as `750` and files as `660`, so
manage recordings over SMB as `sambayom`. Create the directory once on `pve`
before first start. Do not recursively change ownership of existing NAS contents.

```sh
mkdir /mnt/mofp0/data/NAS-YOM/VideoProjects
chown 1001:100 /mnt/mofp0/data/NAS-YOM/VideoProjects
```

MediaMTX requires the mount (`RequiresMountsFor`), so it does not start and write
to the VM disk when the NAS is unavailable. If `network-share` was down at boot,
start it with `systemctl start srv-recordings.mount mediamtx` once it is back.
The mount is `hard`, so writes stall rather than fail during a short NAS outage.
A full disk or storage error can still interrupt recordings. Monitor NAS free
space and service logs; automatic deletion is disabled.

Allow the cameras' VLAN to reach the VM on UDP 8890 and TCP 1935, and trusted
viewing clients on TCP 8888. The configuration currently permits MediaMTX requests
from `10.1.10.0/24`, `10.1.5.0/24`, `10.0.7.0/24`, and localhost. Adjust
`trustedNetworks` if the cameras use another subnet. Routed clients must retain
their source IP for these restrictions to apply.

## Destination settings

Replace `RECORDER_IP` with the VM address, or use
`video-recorder.internal.yomitosh.media` once its DHCP lease registers it.

SRT carries H.265 and is the preferred route. Sony only sends H.264 over RTMP,
which remains as a fallback. MediaMTX selects the path from the SRT stream ID,
so the full URL is:

```text
srt://RECORDER_IP:8890?streamid=publish:a7v
srt://RECORDER_IP:8890?streamid=publish:a7cr
srt://RECORDER_IP:8890?streamid=publish:iphone
```

The RTMP fallback is `rtmp://RECORDER_IP:1935` with the path (`a7v`, `a7cr`,
`iphone`) as stream key. Verify how Creators' App takes the SRT stream ID, with
encryption set to None, during commissioning. On iPhone, use an SRT app such as
Larix Broadcaster in caller mode.

This initial configuration uses unencrypted SRT and RTMP with network-based
access control. The camera names are routing keys, not passwords. Any permitted LAN
client can publish or view those paths. Keep the VM internal, with no
Internet port forwards or public ingress. If traffic must cross an untrusted
network, configure RTMPS with a camera-trusted certificate or an SRT passphrase
and runtime secrets before using that network. Never put credentials in Nix strings.

Browser previews are available while each camera is streaming:

- `http://RECORDER_IP:8888/a7v/`
- `http://RECORDER_IP:8888/a7cr/`
- `http://RECORDER_IP:8888/iphone/`

HLS preview has buffering delay. It is useful for checking framing and that a
feed arrived, but does not by itself prove recordings are being written. H.265
preview depends on browser support; recording does not.

Preview uses MediaMTX's default Low-Latency HLS. Apple devices need HTTPS for it,
so on iPhone or iPad use a Traefik route in home-ops instead of the plain HTTP
URLs. MediaMTX then sees Traefik's address, so viewing is limited by who can reach
that route rather than by `trustedNetworks`.

## Recordings and operation

Files land at:

```text
VideoProjects/a7v/YYYY-MM-DD/HH-MM-SS-microseconds.mp4
VideoProjects/a7cr/YYYY-MM-DD/HH-MM-SS-microseconds.mp4
VideoProjects/iphone/YYYY-MM-DD/HH-MM-SS-microseconds.mp4
```

Files use fragmented MP4 and split at approximately 15-minute boundaries.
A normal disconnect closes the current segment. One-second parts limit the
amount at risk from an interrupted write, although power-loss durability also
depends on the storage stack. No files expire automatically. See
[MediaMTX recording documentation](https://mediamtx.org/docs/features/record).

If an editor needs conventional MP4, remux a completed segment on your
workstation without re-encoding:

```sh
ffmpeg -i recording.mp4 -c copy -movflags +faststart editing-copy.mp4
```

Inspect status and recording errors on the VM:

```sh
systemctl status mediamtx
journalctl -u mediamtx -f
mountpoint /srv/recordings
df -h /srv/recordings
```

Update the installed VM from this repository:

```sh
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#video-recorder \
  --target-host root@RECORDER_IP \
  --build-host root@RECORDER_IP
```

## Commissioning checks

1. Confirm the NAS mount and write permissions on the VM. Check that
   MediaMTX does not start when the NFS mount is missing.
2. Stream one camera for a minute, stop it, and play the resulting file from
   the SMB share. Check image, audio, timestamps, and permissions.
3. Repeat with the other camera, then stream both for at least 30 minutes.
   Check segment boundaries, camera temperature, network stability, disk use,
   and that both files contain the expected audio.
4. Interrupt and reconnect one camera. Confirm a new playable segment appears
   and the other camera continues recording. Compare with card footage.
5. Reboot the VM and verify it resumes accepting streams. A camera may
   need streaming restarted after a server or network outage.

OBS can be added later on a workstation for live scene switching and graphics.
The initial system preserves each camera's feed for editing and removes the
need to open a recording application before every take.
