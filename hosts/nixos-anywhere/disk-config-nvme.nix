{lib, ...}: {
  disko.devices.disk.main.device = lib.mkForce "/dev/nvme0n1";
}
