# SonaMesh VM audio services

The VM runs the SonaMesh routes in `configuration.nix` and the Shairport Sync
receiver in `airplay.nix`. Both use the lingering `sonamesh` user and its PipeWire
session. The SonaMesh input is pinned to the version deployed with the AES67 route.

Select **SonaMesh Speakers** in an Apple device's AirPlay audio picker. AirPlay
stereo passes through `sonamesh.airplay`, which maps FL/FR to UMC1820 AUX0/AUX1.
PipeWire mixes this with SonaMesh playback on that pair. AirPlay volume applies to
its own stream.

This is classic AirPlay. AirPlay 2's NQPTP needs UDP 319/320, already owned by the
SonaMesh AES67 PTP grandmaster. Do not enable NQPTP on the same network endpoint.
The receiver opens TCP 5000 and UDP 6001-6010; Avahi handles discovery. Clients on
other VLANs need mDNS reflection and access to those ports.

Gamebox is an optional client. Its microphone route uses its DHCP hostname;
AirPlay and the other routes do not depend on it being online. The Mac capture
destinations retain their deployed IPs.

## Check the service

Run on the VM as root:

```sh
systemctl --user --machine=sonamesh@.host status shairport-sync.service
avahi-browse -rt _raop._tcp
runuser -u sonamesh -- env XDG_RUNTIME_DIR=/run/user/1000 pw-link -l
```

If restarting PipeWire manually, also restart the existing SonaMesh clients so
they reconnect. Shairport Sync follows PipeWire restarts automatically.

```sh
systemctl --user --machine=sonamesh@.host restart 'sonamesh-*.service'
```

Validation on 2026-09-06: NixOS build and activation passed; native Bonjour on the
Mac discovered the receiver; a five-second silent RAOP stream completed and its
PipeWire links reached AUX0/AUX1. Audible playback still needs a listening check.
