{
  inputs,
  pkgs,
  ...
}: let
  authorizedKeys = import ../shared/authorized-keys.nix {inherit inputs;};
in {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    inputs.sonamesh.nixosModules.default
  ];

  # ── Boot ────────────────────────────────────────────────────────────────
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  # USB audio must remain available while the VM is idle.
  boot.kernelParams = ["usbcore.autosuspend=-1"];
  # Absorb scheduler and network bursts before the bounded userspace playout buffer.
  boot.kernel.sysctl."net.core.rmem_max" = 8 * 1024 * 1024;

  # ── Nix ─────────────────────────────────────────────────────────────────
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  # ── Host ────────────────────────────────────────────────────────────────
  networking = {
    hostName = "sonamesh";
    domain = "internal.yomitosh.media";
    useDHCP = true;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # ── VM integration and administration ──────────────────────────────────
  services.qemuGuest.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  # A lingering user session owns PipeWire and remains active without login.
  users.users.sonamesh = {
    isNormalUser = true;
    description = "SonaMesh audio service";
    home = "/var/lib/sonamesh";
    createHome = true;
    linger = true;
    openssh.authorizedKeys.keys = authorizedKeys;
    extraGroups = ["audio"];
  };

  # ── Audio ───────────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.sonamesh = {
    enable = true;
    pipewire = {
      inputNode = "alsa_input.usb-BEHRINGER_UMC1820_50F63C5A-00.multichannel-input";
      outputNode = "alsa_output.usb-BEHRINGER_UMC1820_50F63C5A-00.multichannel-output";
    };
    inputRoutes = {
      "umc-input-1-macbook" = {
        channel = "AUX0";
        destination = "10.1.10.243:4110";
      };
      "umc-input-1-mac-studio" = {
        channel = "AUX0";
        destination = "10.1.10.242:4110";
      };
      "umc-input-1-gamebox" = {
        channel = "AUX0";
        destination = "gamebox.internal.yomitosh.media:4111";
      };
    };
    outputRoutes = {
      gamebox = {
        port = 4010;
        latency = "20ms";
        channels = ["AUX0" "AUX1"];
      };
      macbook = {
        port = 4011;
        latency = "150ms";
        channels = ["AUX0" "AUX1"];
      };
      "mac-studio-2" = {
        port = 4012;
        latency = "40ms";
        channels = ["AUX0" "AUX1"];
      };
    };
    aes67OutputRoutes."mac-studio-2-v2" = {
      port = 5012;
      channels = ["AUX0" "AUX1"];
      payloadType = 98;
      ssrc = 1397555202;
      presentationDelayMs = 20;
      outputLeadMs = 10;
      bufferPackets = 64;
    };
    ptp = {
      enable = true;
      interface = "ens18";
      domain = 0;
      utcOffset = 37;
    };
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-sonamesh-clock" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [48000];
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 48;
        "default.clock.max-quantum" = 256;
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = false;
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pamixer
    pipewire
    usbutils
    wireplumber
  ];

  system.stateVersion = "26.05";
}
