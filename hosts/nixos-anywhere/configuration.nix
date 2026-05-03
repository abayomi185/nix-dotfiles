# Generic nixos-anywhere target for x86_64-linux hosts.
#

# Install with:
# nix run github:nix-community/nixos-anywhere -- \
#   --flake .#nixos-anywhere-generic \
#   --target-host root@<ip-address>

{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUFAxoqI9FZ1z4X+CVoyqwzdeYj/7uqI19U/hNiVQ41 yomi@MacBook-Air.lan"
  ] ++ (args.extraPublicKeys or []);

  system.stateVersion = "25.11";
}
