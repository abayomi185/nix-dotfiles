# Cross-compile aarch64-linux from this host.
#
# Sets `nix.settings.extra-platforms` so `nix build` of aarch64-linux
# derivations (e.g. a Raspberry Pi 4 SD image) is routed to QEMU
# user-mode emulation. Expect ~10× slowdown vs. native aarch64; the
# first kernel build on a fresh 26.05 nixpkgs takes ~12 hours.
#
# ── PREREQUISITES ────────────────────────────────────────
#
# QEMU user-mode for aarch64 must be registered via binfmt-misc
# SOMEWHERE this host can see it.
#
# NixOS host (e.g. a Proxmox box running NixOS):
#   Add to the HOST's NixOS config — NOT to this LXC container:
#     boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
#
# Debian/Ubuntu host (typical Proxmox install):
#   apt install -y qemu-user-static binfmt-support
#   update-binfmts --enable qemu-aarch64
#
# ── LXC CAVEAT ──────────────────────────────────────────
#
# In an unprivileged LXC container, this module can only enable
# Nix's awareness of the aarch64-linux platform. The binfmt
# registration must happen on the HOST (the container shares the
# host's kernel and can use a pre-registered format, but cannot
# register one itself). Set it on the Proxmox host with the
# `boot.binfmt.emulatedSystems` option above.
#
# ── PERFORMANCE ──────────────────────────────────────────
#
# For native-speed aarch64 builds, add a remote aarch64-linux
# builder to your NixOS config:
#
#   nix.buildMachines = [{
#     hostName = "your-aarch64-builder";
#     sshUser = "nixbuild";
#     systems = [ "aarch64-linux" ];
#     maxJobs = 4;
#     speedFactor = 4;  # native is ~4× faster than QEMU emulation
#   }];
#   nix.distributedBuilds = true;
#
# ─────────────────────────────────────────────────────────
#
# No-op on aarch64 hosts (where native aarch64 builds are used).
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (pkgs.stdenv.hostPlatform.system != "aarch64-linux") {
  nix.settings.extra-platforms = ["aarch64-linux"];
}
