{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  authorizedKeys = import ../../shared/authorized-keys.nix {inherit inputs;};
  recordingDir = "/srv/recordings";
  sourcePaths = ["a7v" "a7cr" "iphone"];
  trustedNetworks = ["10.1.10.0/24" "10.1.5.0/24" "10.0.7.0/24" "127.0.0.1" "::1"];
in {
  imports = ["${modulesPath}/virtualisation/proxmox-lxc.nix"];

  proxmoxLXC = {
    enable = true;
    manageNetwork = false;
    manageHostName = true;
  };
  networking.hostName = "video-recorder";
  networking.domain = "internal.yomitosh.media";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "prohibit-password";
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  # Match sambayom and the NAS users group. lxc.conf maps both IDs straight
  # through to the host, so recordings have the same owner as SMB access.
  users.groups.users.gid = 100;
  users.users.mediamtx = {
    isSystemUser = true;
    uid = 1001;
    group = "users";
  };

  services.mediamtx = {
    enable = true;
    settings = {
      logDestinations = ["stdout"];
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
        recordPath = "${recordingDir}/%path/%Y-%m-%d/%H-%M-%S-%f";
        recordFormat = "fmp4";
        recordPartDuration = "1s";
        recordSegmentDuration = "15m";
        # Project footage must never expire automatically.
        recordDeleteAfter = "0s";
      };
      paths = lib.genAttrs sourcePaths (_: {});
    };
  };

  systemd.services.mediamtx.serviceConfig = {
    DynamicUser = lib.mkForce false;
    Group = lib.mkForce "users";
    UMask = "0007";
    # A missing bind mount must not redirect recordings onto the root disk.
    ExecStartPre = [
      "${pkgs.util-linux}/bin/mountpoint -q ${recordingDir}"
      "${pkgs.coreutils}/bin/test -w ${recordingDir}"
    ];
    RestartSec = "5s";
  };

  # MediaMTX also checks source networks for every publish/read request.
  networking.firewall.allowedTCPPorts = [1935 8888];
  networking.firewall.allowedUDPPorts = [8890];
  environment.systemPackages = with pkgs; [git];
  system.stateVersion = "26.05";
}
