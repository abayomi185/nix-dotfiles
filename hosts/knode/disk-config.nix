{
  lib,
  pDataDiskDevice ? null,
  pDiskDevice ? "/dev/sda",
  ...
}: {
  disko.devices = {
    disk.main = {
      device = lib.mkDefault pDiskDevice;
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

    # Optional second disk for all k3s state: container images and local-path
    # volumes (/var/lib/rancher/k3s/storage) stay off the small root disk.
    disk.data = lib.mkIf (pDataDiskDevice != null) {
      device = pDataDiskDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions.data = {
          name = "data";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var/lib/rancher/k3s";
          };
        };
      };
    };
  };
}
