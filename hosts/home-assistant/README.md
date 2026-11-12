# Home Assistant

NixOS VM for `pve-firewall` on [YHLD-SERV2](https://github.com/abayomi185/homelab/blob/main/devices/YHLD-SERV2/YHLD-SERV2.md),
replacing the HAOS VM (306). HAOS add-ons map to NixOS services:

| HAOS add-on | NixOS |
| --- | --- |
| Mosquitto | `services.mosquitto`, localhost only |
| Zigbee2MQTT | `services.zigbee2mqtt`, CC2652P on SLZB-MR2 `:7638` |
| OpenThread Border Router | `services.openthread-border-router`, EFR32MG21 on SLZB-MR2 `:6638` via socat |
| Matter Server | `services.matter-server` |
| ESPHome Device Builder | `services.esphome` |
| Music Assistant | `services.music-assistant` |
| Whisper | `services.wyoming.faster-whisper` |
| Node-RED | `services.node-red` |
| Frigate, Studio Code Server, Get HACS | dropped |

HACS components: `octopus_energy` comes from nixpkgs. Custom VeSync and Apple TV
Beta are replaced with the built-in `vesync` and `apple_tv` integrations.

The host follows `nixpkgs-unstable`: HA cannot downgrade its database, and stable
lags the HAOS release.

## Provisioning

Create the VM like `video-recorder` on VLAN 10 next to HAOS: 2 vCPU, 2 GiB RAM,
16 GiB `local-lvm`. The `pve-firewall` thin pool is close to full, so keep the
disk small. Install from the repo `livecd` ISO:

```sh
qm create <VMID> --name home-assistant --onboot 1 --startup order=2 \
  --ostype l26 --machine q35 --bios ovmf --efidisk0 local-lvm:0,efitype=4m \
  --cores 2 --memory 2048 --agent 1 \
  --scsihw virtio-scsi-single --scsi0 local-lvm:16,iothread=1,ssd=1,discard=on \
  --net0 virtio,bridge=vmbr5,tag=10 \
  --ide2 local:iso/livecd.iso,media=cdrom --boot 'order=scsi0;ide2'

nix run github:nix-community/nixos-anywhere -- \
  --flake .#home-assistant --build-on remote root@<ISO_IP>
```

## Migration

Take a full HAOS backup (Settings > System > Backups) that includes the database,
then stop HAOS so it releases the radios. Restore from the extracted backup:

| HAOS backup | NixOS path |
| --- | --- |
| `homeassistant.tar.gz` `data/` | `/var/lib/hass` (`.storage`, `home-assistant_v2.db`, `automations.yaml`, …) |
| `homeassistant` `data/zigbee2mqtt/` | `/var/lib/zigbee2mqtt` (`database.db`, `coordinator_backup.json`) |
| `esphome` add-on | `/var/lib/esphome` |
| `nodered` add-on | `/var/lib/node-red` |
| `core_matter_server` add-on | `/var/lib/matter-server` |
| `core_openthread_border_router` add-on | `/var/lib/thread` |
| `music_assistant` add-on | `/var/lib/music-assistant` |

Fix ownership (`chown -R hass:hass /var/lib/hass`, likewise for `zigbee2mqtt`
and `node-red`), then start the services. `esphome` and `matter-server` use
`DynamicUser`, so copy into `/var/lib/private/<name>` while they are stopped.

History and long-term statistics live in `home-assistant_v2.db` and carry over
with it. The old `configuration.yaml` is
replaced by the module config, so merge any YAML-only config into `config`.

Update afterwards:

- the `mqtt` integration's broker: `127.0.0.1`
- the `otbr` integration's URL: `http://127.0.0.1:8081`
- the Music Assistant URL: `http://127.0.0.1:8095`
- the Whisper Wyoming integration: `127.0.0.1:10300`

Restoring `/var/lib/thread` and `/var/lib/matter-server` keeps the Thread network
and Matter fabric. Without them, expect to re-pair Thread/Matter devices.

## Backups

Back up the whole VM to `mobackupserver-main` (PBS) with a Proxmox backup job.
Snapshot mode with the guest agent quiesces the filesystem, so the SQLite
database is consistent. The flake rebuilds the OS, so only `/var/lib` holds
state, but a VM backup is the simplest complete restore.
