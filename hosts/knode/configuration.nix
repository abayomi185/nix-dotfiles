{
  inputs,
  pHostname,
  pK3sRole,
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  secretsPath = builtins.toString inputs.nix-secrets;
  secretsConfig = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");

  k3sToken = secretsConfig.k3s.token;
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.isContainer = true;
  networking.hostName = pHostname;

  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  services.openssh.enable = true;

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

  environment.systemPackages = with pkgs; [
    neovim
  ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  services.k3s = {
    enable = true;
    role = pK3sRole; # "server" or "agent"
    token = k3sToken;
    clusterInit = true;
    extraFlags = toString [
      "--disable=traefik,servicelb"
    ];
    serverAddr =
      if pK3sRole == "agent"
      then "10.0.7.41:6443"
      else null;
  };

  system.stateVersion = "24.05";
}
