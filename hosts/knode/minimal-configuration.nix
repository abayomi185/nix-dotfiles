{modulesPath, ...}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.isContainer = true;
  networking.hostName = "knode";

  time.timeZone = timeZone;

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  # Supress systemd units that don't work because of LXC.
  # https://blog.xirion.net/posts/nixos-proxmox-lxc/#configurationnix-tweak
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  networking.useDHCP = true;

  system.stateVersion = "24.05";
}
