{
  inputs,
  pkgs,
  ...
}: let
  package = inputs.sonamesh.packages.${pkgs.stdenv.hostPlatform.system}.default;
  outputNode = "alsa_output.usb-BEHRINGER_UMC1820_50F63C5A-00.multichannel-output";
  waitForOutput = pkgs.writeShellApplication {
    name = "sonamesh-wait-for-output";
    runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.pipewire];
    text = ''
      attempt=0
      while [ "$attempt" -lt 30 ]; do
        if pw-dump | jq -e --arg target "$1" \
          'any(.[]; .info.props."node.name"? == $target)' >/dev/null
        then
          exit 0
        fi
        sleep 1
        attempt=$((attempt + 1))
      done

      echo "PipeWire output did not appear: $1" >&2
      exit 1
    '';
  };
  verifyReceiver = pkgs.writeShellApplication {
    name = "sonamesh-verify-receiver";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.iproute2];
    text = ''
      attempt=0
      while [ "$attempt" -lt 10 ]; do
        if ss -H -lun 'sport = :4010' | grep -q .; then
          exit 0
        fi
        sleep 0.2
        attempt=$((attempt + 1))
      done

      echo "SonaMesh receiver did not bind UDP port 4010" >&2
      exit 1
    '';
  };
in {
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

  systemd.user.services.sonamesh-receiver = {
    description = "SonaMesh network audio receiver";
    wantedBy = ["default.target"];
    wants = ["pipewire.service" "wireplumber.service"];
    after = ["pipewire.service" "wireplumber.service"];
    unitConfig = {
      StartLimitIntervalSec = 30;
      StartLimitBurst = 10;
    };
    serviceConfig = {
      Type = "exec";
      ExecStartPre = "${waitForOutput}/bin/sonamesh-wait-for-output ${outputNode}";
      ExecStart = "${package}/bin/sonamesh pipewire-receive --bind 0.0.0.0:4010 --target ${outputNode} --latency 10ms --jitter-packets 8";
      ExecStartPost = "${verifyReceiver}/bin/sonamesh-verify-receiver";
      Restart = "always";
      RestartSec = "1s";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "sonamesh-receiver";
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
    package
    alsa-utils
    pamixer
    pipewire
    usbutils
    wireplumber
  ];

  system.stateVersion = "26.05";
}
