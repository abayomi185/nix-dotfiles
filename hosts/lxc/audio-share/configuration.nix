{
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  hostname = "l-audio-share";
  ipv4_cluster_address = "10.0.7.203";
in {
  imports = [
    # Include the proxmox lxc configuration.
    "${modulesPath}/virtualisation/proxmox-lxc.nix"

    # For common settings across all LXC containers.
    ../common.nix
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  proxmoxLXC = {
    enable = true;
    manageNetwork = true;
    manageHostName = true;
  };

  boot.isContainer = true;

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

  environment.systemPackages = with pkgs; [git pamixer scream];

  networking.hostName = hostname;
  networking.useDHCP = true;
  networking.interfaces = {
    eth1 = {
      ipv4.addresses = [
        {
          address = ipv4_cluster_address;
          prefixLength = 24;
        }
      ];
    };
  };

  users.groups = {
    users = {
      gid = 100;
    };
  };

  users.users = {
    audio = {
      isSystemUser = true;
      description = "Audio user";
      group = "audio";
      createHome = false;
    };
  };

  services.avahi.enable = true;

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pipe";
        bitrate = 320;
        device_name = "spotify-daemon";
        device_type = "speaker";
        initial_volume = 20;
        volume_controller = "softvol";
        volume_normalisation = true;
      };
    };
  };

  # rtkit allows Pipewire to use the realtime scheduler for increased performance.
  # security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # opens UDP ports 6001-6002
    # for AirPlay support
    raopOpenFirewall = true;

    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
            # increase the buffer size if you get dropouts/glitches
            # args = {
            #   "raop.latency.ms" = 500;
            # };
          }
        ];
      };
    };
  };

  networking.firewall.allowedUDPPorts = [4010]; # Default scream port
  systemd.services.scream = {
    enable = false;
    description = "Scream Receiver";
    after = ["pipewire.service" "network-online.target"];
    wants = ["pipewire.service" "network-online.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${pkgs.scream}/bin/scream -u -i ${ipv4_cluster_address}";
      Restart = "always";
      RestartSec = 1;
    };
  };

  system.stateVersion = "24.11";
}
