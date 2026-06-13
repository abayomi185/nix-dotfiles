# Raspberry Pi 4 wifi-repeater host entry point.
#
# - Pi 4B / Pi 400 (aarch64-linux)
# - eth0 upstream (DHCP from main router, long cable to basement)
# - wlan0 (AWUS0360ACS, RTL8811AU) downstream as 2.4 GHz AP for the Tesla
# - Driver: morrownr/8821au-20210708 (nixpkgs `rtl8821au`)
# - Flash via: `nix build .#wifi-repeater.config.system.build.sdImage`
#
# See ./configuration.nix for system config; ./README.md for flashing.
{
  inputs,
  outputs,
  ...
}:
inputs.nixos-raspberrypi.lib.nixosSystem {
  specialArgs = {inherit inputs outputs;};
  modules = [
    # Board support (kernel, bootloader, firmware, DTBs).
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    # Flashable SD image builder (config.system.build.sdImage).
    inputs.nixos-raspberrypi.nixosModules.sd-image
    # Encrypted secrets at activation time.
    inputs.sops-nix.nixosModules.sops
    # Available for future nixos-anywhere reinstalls.
    inputs.disko.nixosModules.disko
    ./configuration.nix
  ];
}
