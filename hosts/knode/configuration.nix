{
  config,
  inputs,
  pNodeId,
  pK3sRole,
  pK3sServerId,
  pK3sClusterInit,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
  };

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

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
      "--tls-san=knode${pNodeId}.internal.yomitosh.media"
    ];
    serverAddr =
      if pK3sServerId != ""
      then "https://knode${pK3sServerId}.cluster.internal.yomitosh.media:6443"
      else "";
  };

  system.stateVersion = "24.05";
}
