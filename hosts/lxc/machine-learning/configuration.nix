{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  hostname = "machine-learning";
  ipv4_lan_address = "10.0.1.250";
  ipv4_cluster_address = "10.0.7.250";
  default_gateway = "10.0.1.1";
  nameservers = ["10.0.1.53"];
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

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

  environment.systemPackages = with pkgs; [
    llama-cpp
    neovim
    uv
  ];

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
  networking.nameservers = nameservers;

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.181";
      ha256_64bit = "sha256-8G0lzj8YAupQetpLXcRrPCyLOFA9tvaPPvAWurjj3Pk=";
      sha256_aarch64 = "sha256-1pUDdSm45uIhg0HEhfhak9XT/IE/XUVbdtrcpabZ3KU=";
      openSha256 = "sha256-U/uqAhf83W/mns/7b2cU26B7JRMoBfQ3V6HiYEI5J48=";
      settingsSha256 = "sha256-iBx/X3c+1NSNmG+11xvGyvxYSMbVprijpzySFeQVBzs=";
      persistencedSha256 = "sha256-RoAcutBf5dTKdAfkxDPtMsktFVQt5uPIPtkAkboQwcQ=";
    };
  };

  users.groups = {
    users = {
      gid = 100;
    };
  };

  users.users.ml = {
    isNormalUser = true;
    description = "ai/ml";
    shell = pkgs.zsh;
    extraGroups = ["docker" "wheel"];
  };

  programs.bash.interactiveShellInit = ''
    alias fetch_pull_rebuild="git fetch --all && git reset --hard origin/main && nixos-rebuild switch --flake .#load-balancer"
  '';

  programs.git = {
    enable = true;
    config = {
      pull.rebase = true;
      user = {
        name = "Yomi Ikuru";
        email = "yomi+git_homelab_lxc_ml@yomitosh.com";
      };
    };
  };

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

  services.llama-swap = {
    enable = true;
    port = 11343;
    openFirewall = true;
    settings = {
      healthCheckTimeout = 240;
      logLevel = "info";
      metricsMaxInMemory = 1000;
      startPort = 10001;

      macros = {
        latest-llama = ''${pkgs.llama-cpp}/bin/llama-server --port $${PORT}'';
      };

      models = {
        "local:qwen3-default" = {
          cmd = ''$${latest-llama} -hf unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:Q4_K_M --jinja --rope-scaling yarn --rope-scale 4 --yarn-orig-ctx 32768 -np 4'';
          name = "Qwen3-30B-A3B-Instruct-2507-GGUF:Q4_K_M";
          description = "Default model";
          ttl = 600;
          useModelName = "ylac/Qwen3-30B-A3B-Instruct-2507-GGUF:Q4_K_M";
        };

        "local:gpt-oss-20b" = {
          cmd = ''$${latest-llama} -hf unsloth/gpt-oss-20b-GGUF:F16 --jinja'';
          name = "gpt-oss-20b-GGUF:F16";
          description = "GPT-OSS 20B GGUF model";
          ttl = 600;
          useModelName = "ylac/gpt-oss-20b-GGUF:F16";
        };
      };

      hooks = {
        on_startup = {
          preload = [
            "qwen3-default"
          ];
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
