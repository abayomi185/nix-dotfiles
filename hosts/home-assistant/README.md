# Home Assistant

NixOS VM on `pve-firewall` ([YHLD-SERV2](https://github.com/abayomi185/homelab/blob/main/devices/YHLD-SERV2/YHLD-SERV2.md)),
replacing the HAOS VM (306). Follows `nixpkgs-unstable`: HA cannot downgrade
its database.

| HAOS add-on | NixOS |
| --- | --- |
| Mosquitto | `services.mosquitto`, localhost only |
| Zigbee2MQTT | `services.zigbee2mqtt`, SLZB-MR2 `:7638` |
| OpenThread Border Router | `services.openthread-border-router`, SLZB-MR2 `:6638` via socat |
| Matter Server | `services.matterjs-server` |
| ESPHome Device Builder | `services.esphome` |
| Music Assistant | `services.music-assistant` |

Sidebar panels embed the add-on UIs through LAN HTTPS routes in home-ops
(`music`, `zigbee`, `esphome` `.local.yomitosh.media`).

Zigbee device names live in `zigbee-devices.nix`; rename devices there, not in
the Z2M frontend. The network key and PAN IDs are Z2M defaults; leave them unset.

## Provisioning

UEFI VM on VLAN 10: 2 vCPU, 2 GiB RAM, 24 GiB `local-lvm`. It keeps HAOS's
hostname `home` and MAC, so `home.internal.yomitosh.media` is unchanged.
Never run it alongside HAOS: both would claim the SLZB radios.

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#home-assistant --build-on remote root@<LIVECD_IP>
```

## Migration from HAOS

With HAOS stopped, copy from its `hassos-data` partition (`supervisor/`):

| HAOS | NixOS |
| --- | --- |
| `homeassistant/` (minus `configuration.yaml`) | `/var/lib/hass` |
| `homeassistant/zigbee2mqtt/` | `/var/lib/zigbee2mqtt` |
| `homeassistant/esphome/` | `/var/lib/esphome` |
| `apps/data/core_matter_server/` | `/var/lib/private/matterjs-server` |
| `apps/data/core_openthread_border_router/thread/` | `/var/lib/thread` |
| `apps/data/d5369777_music_assistant/` | `/var/lib/private/music-assistant` |

Then point integrations at localhost (MQTT `127.0.0.1:1883`, OTBR
`http://127.0.0.1:8081`, Matter `ws://127.0.0.1:5580/ws`, Music Assistant
`http://127.0.0.1:8095`) and delete the `hassio` integration.
