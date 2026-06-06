# Hardware — Proxmox QEMU guest. Filesystems and the boot device come from
# disko-config.nix, so they are intentionally not declared here.
#
# Regenerate at install time with nixos-anywhere:
#   nix run github:nix-community/nixos-anywhere -- \
#     --flake .#firewall \
#     --generate-hardware-config nixos-generate-config \
#       ./hosts/firewall/hardware-configuration.nix \
#     --target-host root@<installer-ip>
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
