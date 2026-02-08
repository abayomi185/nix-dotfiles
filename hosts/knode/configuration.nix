{
  config,
  inputs,
  pNodeId,
  pK3sRole,
  pK3sServerId,
  pK3sClusterInit,
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
    sandbox = false;
  };

  boot.isContainer = true;
  networking.hostName = "knode${pNodeId}";

  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  sops = {
    age.sshKeyPaths = ["/root/.ssh/id_ed25519"];
    defaultSopsFile = "${inputs.nix-secrets}/hosts/knode/default.enc.yaml";
    secrets = {
      k3s_token = {};
    };
  };

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

  # environment.systemPackages = with pkgs; [];

  networking.useDHCP = true;
  networking.interfaces = {
    eth1 = {
      ipv4.addresses = [
        {
          address = "10.0.7.4${pNodeId}";
          prefixLength = 24;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  programs.git = {
    enable = true;
    config = {
      pull.rebase = true;
    };
  };

  services.k3s = {
    enable = true;
    role = pK3sRole; # "server" or "agent"
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = pK3sClusterInit;
    extraFlags = toString [
      "--disable=traefik,servicelb"
      "--tls-san=knode${pNodeId}.cluster.internal.yomitosh.media"
    ];
    serverAddr =
      if pK3sServerId != ""
      then "https://knode${pK3sServerId}.cluster.internal.yomitosh.media:6443"
      else "";
  };

  systemd.services.createDevKmsgSymlink = {
    description = "Create /dev/kmsg symlink to /dev/console for kubelet";
    after = ["sysinit.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ["${pkgs.coreutils}/bin/ln -sf /dev/console /dev/kmsg"];
      RemainAfterExit = true;
    };
    wantedBy = ["multi-user.target"];
  };

  system.stateVersion = "24.05";
}
