{
  config,
  inputs,
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  hostname = "k-lb";
  ipv4_lan_address = "10.0.1.40";
  ipv4_cluster_address = "10.0.7.40";
  default_gateway = "10.0.1.1";
  nameservers = ["10.0.1.53"];

  traefikEnvSecretsSopsFile = "${inputs.nix-secrets}/hosts/lxc/load-balancer/traefik.enc.env";

  traefik_staticConfig = import ./traefik/static_config.nix {inherit config inputs;};

  traefik_dynamicConfig = import ./traefik/dynamic_config.nix {inherit inputs;};
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  sops.secrets.traefikEnv = {
    format = "dotenv";
    sopsFile = traefikEnvSecretsSopsFile;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

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

  environment.systemPackages = with pkgs; [git neovim];

  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = ipv4_lan_address;
          prefixLength = 24;
        }
      ];
    };
    eth1 = {
      ipv4.addresses = [
        {
          address = ipv4_cluster_address;
          prefixLength = 24;
        }
      ];
    };
  };
  networking.defaultGateway = default_gateway;
  networking.firewall.allowedTCPPorts = [80 443];
  networking.nameservers = nameservers;

  users.groups = {
    users = {
      gid = 100;
    };
  };

  programs.bash.interactiveShellInit = ''
    alias fetch_pull_rebuild="git fetch --all && git reset --hard origin/main && nixos-rebuild switch --flake .#load-balancer"
  '';

  services.traefik = {
    enable = true;
    dynamicConfigOptions = traefik_dynamicConfig;
    staticConfigOptions = traefik_staticConfig;
    environmentFiles = [
      config.sops.secrets.traefikEnv.path
    ];
  };

  system.stateVersion = "24.11";
}
