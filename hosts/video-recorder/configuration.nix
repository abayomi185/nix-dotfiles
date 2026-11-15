{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  authorizedKeys = import ../shared/authorized-keys.nix {inherit inputs;};
  recordingDir = "/srv/recordings";
  nasExport = "network-share.internal.yomitosh.media:/mnt/mofp0/data/NAS-YOM/VideoProjects";
  sourcePaths = ["a7v" "a7cr" "iphone13pro" "iphone17pro"];
  trustedNetworks = ["10.1.10.0/24" "10.1.5.0/24" "10.0.7.0/24" "127.0.0.1" "::1"];
  # Sony Creators' App strips everything after a colon in the SRT URL, so
  # MediaMTX's `publish:<path>` stream ID can't be set. Each camera gets its own
  # port, and a relay forwards it to MediaMTX as MPEG-TS over localhost UDP.
  # A second SRT hop would add another fixed 120 ms delay; loopback needs no
  # retransmission.
  sonySrtRelays = {
    a7v = 8891;
    a7cr = 8892;
  };
  relayUdpPort = port: port + 1000;
in {
  imports = ["${modulesPath}/profiles/qemu-guest.nix"];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.qemuGuest.enable = true;

  networking = {
    hostName = "video-recorder";
    domain = "internal.yomitosh.media";
    useDHCP = true;
  };
  # Lets MediaMTX set its UDP read buffer (udpReadBufferSize).
  boot.kernel.sysctl."net.core.rmem_max" = 8388608;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "prohibit-password";
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  # Match sambayom and the NAS users group, so recordings written over NFS
  # have the same owner as SMB access.
  users.groups.users.gid = 100;
  users.users.mediamtx = {
    isSystemUser = true;
    uid = 1001;
    group = "users";
  };

  fileSystems.${recordingDir} = {
    device = nasExport;
    fsType = "nfs";
    options = ["nfsvers=4.2" "hard"];
  };

  services.mediamtx = {
    enable = true;
    settings = {
      logDestinations = ["stdout"];
      # Headroom so a brief stall doesn't drop relay UDP packets.
      udpReadBufferSize = 8388608;
      # RTMP and unencrypted SRT are LAN-only. Authentication below limits
      # access by source network, not stream key.
      authMethod = "internal";
      authInternalUsers = [
        {
          user = "any";
          ips = trustedNetworks;
          permissions =
            lib.concatMap (path: [
              {
                action = "publish";
                inherit path;
              }
              {
                action = "read";
                inherit path;
              }
            ])
            sourcePaths;
        }
      ];
      api = false;
      metrics = false;
      pprof = false;
      playback = false;
      rtsp = false;
      rtmp = true;
      rtmpAddress = ":1935";
      hls = true;
      hlsAddress = ":8888";
      hlsAllowOrigins = [];
      webrtc = false;
      srt = true;
      srtAddress = ":8890";
      pathDefaults = {
        source = "publisher";
        overridePublisher = false;
        record = true;
        recordPath = "${recordingDir}/%path/%Y-%m-%d_%H-%M-%S-%f";
        recordFormat = "fmp4";
        recordPartDuration = "1s";
        recordSegmentDuration = "15m";
        # Project footage must never expire automatically.
        recordDeleteAfter = "0s";
      };
      paths = lib.genAttrs sourcePaths (path:
        lib.optionalAttrs (sonySrtRelays ? ${path}) {
          source = "udp+mpegts://127.0.0.1:${toString (relayUdpPort sonySrtRelays.${path})}";
        });
    };
  };

  systemd.services =
    {
      mediamtx = {
        # A missing NAS mount must not redirect recordings onto the root disk.
        unitConfig.RequiresMountsFor = recordingDir;
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          Group = lib.mkForce "users";
          UMask = "0007";
          RestartSec = "5s";
        };
      };
    }
    // lib.mapAttrs' (path: port:
      lib.nameValuePair "srt-relay-${path}" {
        description = "SRT relay for ${path}";
        # Start and stop with MediaMTX, including after NAS mount recovery.
        after = ["mediamtx.service"];
        bindsTo = ["mediamtx.service"];
        wantedBy = ["mediamtx.service"];
        serviceConfig = {
          # Exit when the camera disconnects; systemd starts a fresh listener.
          # MediaMTX closes the recording after readTimeout (10s) without data.
          ExecStart = "${pkgs.srt}/bin/srt-live-transmit -a:no 'srt://:${toString port}?mode=listener' 'udp://127.0.0.1:${toString (relayUdpPort port)}'";
          DynamicUser = true;
          Restart = "always";
          RestartSec = "1s";
        };
      })
    sonySrtRelays;

  # MediaMTX also checks source networks for every publish/read request. Relay
  # ports bypass that (MediaMTX sees 127.0.0.1), so the VM must stay LAN-only.
  networking.firewall.allowedTCPPorts = [1935 8888];
  networking.firewall.allowedUDPPorts = [8890] ++ lib.attrValues sonySrtRelays;
  environment.systemPackages = with pkgs; [git];
  system.stateVersion = "26.05";
}
