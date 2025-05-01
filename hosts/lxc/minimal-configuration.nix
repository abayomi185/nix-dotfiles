{
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  hostname = "temp_lxc_node";
  default_gateway = "10.0.1.1";
  nameservers = ["10.0.1.53"];

  ipv4_address = "10.0.1.254";
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.isContainer = true;
  networking.hostName = hostname;

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

  environment.systemPackages = with pkgs; [git];

  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = ipv4_address;
          prefixLength = 24;
        }
      ];
    };
  };
  networking.defaultGateway = default_gateway;
  networking.nameservers = nameservers;

  system.stateVersion = "24.05";
}
