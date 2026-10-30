# Video recorder

NixOS LXC guest for `pve` on [YHLD-SERV1](https://github.com/abayomi185/homelab/blob/main/devices/YHLD-SERV1/YHLD-SERV1.md).
MediaMTX receives two camera streams and records them independently without
transcoding. No GPU, desktop session, OBS instance, or capture card is needed.

```text
Sony a7V  ── Wi-Fi / Ethernet ──┐
                              ├── video-recorder LXC ── NAS bind mount
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

## Guest provisioning

This configuration has not provisioned a running container or allocated an IP.
Choose a free CT ID and reserve a guest address in the homelab inventory before
creation. Physical-host configuration remains in the homelab repository.

[`lxc.conf`](./lxc.conf) is the guest template: unprivileged, 2 vCPU, 2 GiB RAM,
8 GiB root volume, `nesting=1`, boot at host startup. Add one network interface
with a reachable reserved address; Proxmox supplies the network settings. No
device passthrough or privileged container is needed.

Build the template on an x86_64 Linux Nix machine from a checkout containing
these files. New files must be added to Git before using a Git flake checkout.

```sh
nix build .#nixosConfigurations.video-recorder.config.system.build.tarball
```

Upload the resulting `result/tarball/*.tar.xz` to Proxmox template storage and
create the container from it. Configure networking in Proxmox and add a bind
mount before starting the recorder.

Proposed storage directory on the existing NAS dataset:
`/mnt/mofp0/data/NAS-YOM/VideoProjects`. Bind only this directory into the
recorder as `/srv/recordings`, read/write. Confirm the real dataset mount is
healthy on pve before creating the directory. Avoid mounting the entire NAS
into the recorder. Bind-mounted footage is outside the container root disk and
is not included in ordinary container backups. Cover it with the NAS backup
policy separately.

The service runs as guest UID 1001, GID 100. The `lxc.idmap` lines in `lxc.conf`
map both straight through to host UID 1001, GID 100, the same identity as
`sambayom` in the privileged `network-share` guest. MediaMTX creates directories
as `750` and files as `660`, so manage recordings over SMB as `sambayom`.

Before starting the guest, allow the mapping on `pve` and hand it the directory.
Do not recursively change ownership of existing NAS contents.

```sh
echo 'root:1001:1' >> /etc/subuid
echo 'root:100:1' >> /etc/subgid
mkdir /mnt/mofp0/data/NAS-YOM/VideoProjects
chown 1001:100 /mnt/mofp0/data/NAS-YOM/VideoProjects
```

The existing `network-share` exports already include the parent `NAS-YOM`
directory. Files can be accessed through its existing NFS export or the
`SharedData` SMB share under `NAS-YOM/VideoProjects`, subject to these permissions.
No change to network-share is needed.

The service checks that `/srv/recordings` is a mount point and writable before
starting. Without it, the service fails and retries. Once running, a full disk
or storage error can still interrupt recordings. Monitor NAS free space and
service logs; automatic deletion is disabled.

Allow the cameras' VLAN to reach the guest on UDP 8890 and TCP 1935, and trusted
viewing clients on TCP 8888. The configuration currently permits MediaMTX requests
from `10.1.10.0/24`, `10.1.5.0/24`, `10.0.7.0/24`, and localhost. Adjust
`trustedNetworks` if the cameras use another subnet. Routed clients must retain
their source IP for these restrictions to apply.

## Destination settings

Replace `RECORDER_IP` with the reserved guest address. An internal DNS record
for `video-recorder.internal.yomitosh.media` can be added once allocated.

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
client can publish or view those paths. Keep the guest internal, with no
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

Inspect status and recording errors inside the container:

```sh
systemctl status mediamtx
journalctl -u mediamtx -f
mountpoint /srv/recordings
df -h /srv/recordings
```

Update an installed guest from this repository:

```sh
nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake .#video-recorder \
  --target-host root@RECORDER_IP \
  --build-host root@RECORDER_IP
```

## Commissioning checks

1. Confirm the NAS mount and write permissions inside the guest. Check that
   starting MediaMTX without the bind mount fails instead of writing locally.
2. Stream one camera for a minute, stop it, and play the resulting file from
   the SMB share. Check image, audio, timestamps, and permissions.
3. Repeat with the other camera, then stream both for at least 30 minutes.
   Check segment boundaries, camera temperature, network stability, disk use,
   and that both files contain the expected audio.
4. Interrupt and reconnect one camera. Confirm a new playable segment appears
   and the other camera continues recording. Compare with card footage.
5. Reboot the guest and verify it resumes accepting streams. A camera may
   need streaming restarted after a server or network outage.

OBS can be added later on a workstation for live scene switching and graphics.
The initial system preserves each camera's feed for editing and removes the
need to open a recording application before every take.
