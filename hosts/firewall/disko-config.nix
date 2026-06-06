# Disk layout (disko) — GPT with BIOS-boot + ESP + ext4 root, matching the
# knodes / nixos-anywhere hosts. Provisioned by nixos-anywhere.
#
# Proxmox: attach the disk to a VirtIO SCSI controller (-> /dev/sda). Adjust the
# device below if you use VirtIO Block (/dev/vda) instead.
{lib, ...}: {
  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
