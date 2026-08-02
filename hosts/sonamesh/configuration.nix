{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  # ── Boot ────────────────────────────────────────────────────────────────
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  # USB audio must remain available while the VM is idle.
  boot.kernelParams = ["usbcore.autosuspend=-1"];

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
    firewall.allowedUDPPorts = [4010];
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
  users.users.root.openssh.authorizedKeys.keys =
    import ../shared/authorized-keys.nix {inherit inputs;};

  # A lingering user session owns PipeWire and remains active without login.
  users.users.sonamesh = {
    isNormalUser = true;
    description = "SonaMesh audio service";
    home = "/var/lib/sonamesh";
    createHome = true;
    linger = true;
    extraGroups = ["audio"];
  };

  # ── Audio ───────────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-sonamesh-clock" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [48000];
        "default.clock.min-quantum" = 48;
        "default.clock.max-quantum" = 1024;
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
