# Hardware configuration for the firewall VM (QEMU/Proxmox)
#
# IMPORTANT: This is a best-effort placeholder. Generate the real
# hardware config by running on the actual VM:
#   nixos-generate-config --show-hardware-config
# and replacing the boot/filesystem sections below.
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

  # Boot loader - adjust based on your VM's boot method
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda"; # Adjust to match your VM disk
  };

  # Filesystem - adjust to match your VM disk layout
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
