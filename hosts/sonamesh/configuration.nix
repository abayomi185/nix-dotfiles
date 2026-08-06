{
  inputs,
  lib,
  pkgs,
  ...
}: let
  authorizedKeys = import ../shared/authorized-keys.nix {inherit inputs;};
  package = inputs.sonamesh.packages.${pkgs.stdenv.hostPlatform.system}.default;
  outputNode = "alsa_output.usb-BEHRINGER_UMC1820_50F63C5A-00.multichannel-output";
  receiverSources = {
    gamebox = 4010;
    macbook = 4011;
    "mac-studio-2" = 4012;
  };
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
        if ss -H -lun "sport = :$1" | grep -q .; then
          exit 0
        fi
        sleep 0.2
        attempt=$((attempt + 1))
      done

      echo "SonaMesh receiver did not bind UDP port $1" >&2
      exit 1
    '';
  };
  mkReceiver = {
    source,
    port,
  }: {
    description = "SonaMesh ${source} audio receiver";
    wantedBy = ["default.target"];
    wants = ["pipewire.service" "wireplumber.service"];
    after = ["pipewire.service" "wireplumber.service"];
    unitConfig = {
      ConditionUser = "sonamesh";
      StartLimitIntervalSec = 30;
      StartLimitBurst = 10;
    };
    serviceConfig = {
      Type = "exec";
      ExecStartPre = "${waitForOutput}/bin/sonamesh-wait-for-output ${outputNode}";
      ExecStart = "${package}/bin/sonamesh pipewire-receive --bind 0.0.0.0:${toString port} --target ${outputNode} --latency 20ms --jitter-packets 4";
      ExecStartPost = "${verifyReceiver}/bin/sonamesh-verify-receiver ${toString port}";
      Restart = "always";
      RestartSec = "1s";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "sonamesh-receiver-${source}";
    };
  };
  receiverServices =
    lib.mapAttrs' (
      source: port:
        lib.nameValuePair "sonamesh-receiver-${source}" (mkReceiver {inherit source port;})
    )
    receiverSources;
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
    firewall.allowedUDPPorts = builtins.attrValues receiverSources;
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

  systemd.user.services = receiverServices;

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
