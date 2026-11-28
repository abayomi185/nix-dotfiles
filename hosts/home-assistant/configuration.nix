{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  authorizedKeys = import ../shared/authorized-keys.nix {inherit inputs;};
  # SLZB-MR2 (YHLD-SLZB1): EFR32MG21 Thread RCP and CC2652P Zigbee coordinator.
  slzb = "slzb-mr2.internal.yomitosh.media";
  otbrRadio = "/run/otbr-radio";
  lan = "lan0";
  musickitEnv = "/run/music-assistant-musickit.env";
  musickitToken =
    pkgs.writers.writePython3 "musickit-token" {
      libraries = with pkgs.python3Packages; [cryptography pyjwt];
    } ''
      import os
      import sys
      import time

      import jwt


      def read(path):
          with open(path) as f:
              return f.read().strip()


      key, key_id, team_id = (read(p) for p in sys.argv[1:4])
      now = int(time.time())
      token = jwt.encode(
          {"iss": team_id, "iat": now, "exp": now + 180 * 86400},
          key,
          algorithm="ES256",
          headers={"kid": key_id},
      )
      fd = os.open(sys.argv[4], os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
      with os.fdopen(fd, "w") as f:
          f.write(f"MASS_APP_VAR_APPLE_MUSIC_TOKEN={token}\n")
    '';
  # Sidebar webpage panels for the add-on UIs (LAN HTTPS routes in home-ops).
  panels = {
    addon-music = {
      title = "Music Assistant";
      icon = "mdi:music";
      url = "https://music.home.local.yomitosh.media";
      admin = false;
    };
    addon-zigbee = {
      title = "Zigbee2MQTT";
      icon = "mdi:zigbee";
      url = "https://zigbee.home.local.yomitosh.media";
      admin = true;
    };
    addon-esphome = {
      title = "ESPHome";
      icon = "mdi:chip";
      url = "https://esphome.home.local.yomitosh.media";
      admin = true;
    };
  };
in {
  imports = ["${modulesPath}/profiles/qemu-guest.nix"];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.qemuGuest.enable = true;

  networking = {
    # Matches HAOS, so home.internal.yomitosh.media (mobile apps, hass-cli)
    # keeps resolving via DHCP.
    hostName = "home";
    domain = "internal.yomitosh.media";
    useDHCP = true;
  };
  # Stable NIC name for OTBR and Matter; HAOS sees this NIC as enp6s18.
  systemd.network.links."10-lan" = {
    matchConfig.Driver = "virtio_net";
    linkConfig.Name = lan;
  };
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

  # ── Home Assistant ──────────────────────────────────────
  services.home-assistant = {
    enable = true;
    # HomeKit bridge: TCP 21063, mDNS UDP 5353.
    openFirewallForComponents = true;
    extraComponents = [
      "analytics"
      "backup"
      "default_config"
      "esphome"
      "go2rtc"
      "google_translate"
      "homekit"
      "isal"
      "matter"
      "met"
      "mobile_app"
      "mqtt"
      "music_assistant"
      "otbr"
      "speedtestdotnet"
      "spotify"
      "sun"
      "thread"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      octopus_energy
    ];
    config = {
      default_config = {};
      # The HAOS config entry was imported from YAML; keep it declared.
      homekit = {};
      tts = [{platform = "google_translate";}];
      # UI-managed files stay mutable in /var/lib/hass.
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
      lovelace.dashboards =
        lib.mapAttrs (slug: p: {
          mode = "yaml";
          title = p.title;
          icon = p.icon;
          show_in_sidebar = true;
          require_admin = p.admin;
          filename = "panels/${slug}.yaml";
        })
        panels;
    };
  };

  systemd.tmpfiles.rules =
    ["d /var/lib/hass/panels 0755 hass hass"]
    ++ lib.mapAttrsToList (slug: p: let
      file = pkgs.writeText "${slug}.yaml" (builtins.toJSON {
        strategy = {
          type = "iframe";
          url = p.url;
        };
      });
    in "L+ /var/lib/hass/panels/${slug}.yaml - - - - ${file}")
    panels;

  # ── Zigbee ──────────────────────────────────────────────
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "127.0.0.1";
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        acl = ["topic readwrite #"];
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant.enabled = true;
      mqtt.server = "mqtt://127.0.0.1:1883";
      serial = {
        port = "tcp://${slzb}:7638";
        adapter = "zstack";
      };
      # WARN: the network runs on Z2M defaults (no network_key/pan_id/ext_pan_id
      # in the HAOS config; coordinator backup: PAN 0x1a62, channel 11). Leave
      # them unset, or set them to match coordinator_backup.json, or re-pair.
      advanced.transmit_power = 20;
      # Declarative: renames in the Z2M frontend are lost on restart.
      devices = import ./zigbee-devices.nix;
      groups = {};
      frontend.enabled = true;
    };
  };
  # The coordinator is reached by hostname over TCP.
  systemd.services.zigbee2mqtt = {
    after = ["network-online.target" "mosquitto.service"];
    wants = ["network-online.target"];
  };

  # ── Thread / Matter ─────────────────────────────────────
  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [lan];
    radio = {
      device = otbrRadio;
      baudRate = 460800;
    };
    rest.listenAddress = "127.0.0.1";
  };

  # otbr-agent only speaks serial, so bridge the network RCP to a pty, as the
  # HAOS add-on does.
  systemd.services.otbr-radio = {
    wantedBy = ["multi-user.target"];
    before = ["otbr-agent.service"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    # bindsTo stops the agent when the bridge drops; upholds restarts it.
    upholds = ["otbr-agent.service"];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat pty,raw,echo=0,link=${otbrRadio},ignoreeof tcp:${slzb}:6638";
      Restart = "always";
      RestartSec = "5s";
    };
  };
  systemd.services.otbr-agent = {
    bindsTo = ["otbr-radio.service"];
    after = ["otbr-radio.service"];
  };

  # The HAOS add-on (9.x) runs matter.js; python matter-server cannot read its
  # storage. Flags mirror the add-on so the existing fabric is reused.
  services.matterjs-server = {
    enable = true;
    extraArgs = [
      "--fabricid=2"
      "--vendorid=4939"
      "--primary-interface=${lan}"
      "--enable-time-sync"
    ];
  };
  # matter.js keeps a pid lock that survives crashes and reboots; a reused pid
  # then blocks startup. systemd already guarantees a single instance. Runs as
  # root (+): the files may not belong to the current dynamic user.
  systemd.services.matterjs-server.serviceConfig = {
    ExecStartPre = "+${pkgs.findutils}/bin/find -H %S/matterjs-server -maxdepth 2 ( -name matter.lock -o -name matter.pid ) -delete";
    Restart = "on-failure";
    RestartSec = "10s";
  };

  # ── Add-on replacements ─────────────────────────────────
  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    openFirewall = true;
  };

  services.music-assistant = {
    enable = true;
    openFirewall = true;
    providers = [
      "airplay"
      "apple_music"
      "builtin"
      "chromecast"
      "hass"
      "hass_players"
      "radiobrowser"
      "spotify"
    ];
  };
  # nixpkgs builds MA from source, without the bundled provider credentials of
  # official builds; app_var() reads these overrides first.
  systemd.services.music-assistant = {
    environment = {
      # Own Spotify app; redirect URI https://music-assistant.io/callback.
      MASS_APP_VAR_SPOTIFY_CLIENT_ID = "ad0188d08b8e4b318cfe0fd107cc2693";
    };
    # MusicKit developer token (JWT, max 6 months), signed from our key on
    # every start so it never needs renewing by hand.
    serviceConfig = {
      ExecStartPre = "+${musickitToken} ${
        lib.concatMapStringsSep " " (s: config.sops.secrets.${s}.path) [
          "musickit_key"
          "musickit_key_id"
          "musickit_team_id"
        ]
      } ${musickitEnv}";
      EnvironmentFile = "-${musickitEnv}";
      # systemd mounts the DynamicUser state dir noexec; Soloist is downloaded
      # into it and must run from there.
      ExecPaths = ["-/var/lib/private/music-assistant/soloist"];
    };
  };

  # Music Assistant downloads Spotify Soloist, a generic glibc binary.
  programs.nix-ld.enable = true;

  # ── Secrets (sops, decrypted with the host SSH key) ─────
  sops = {
    defaultSopsFile = "${inputs.nix-secrets}/hosts/home-assistant/default.enc.yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      musickit_key = {};
      musickit_key_id = {};
      musickit_team_id = {};
    };
  };

  networking.firewall.allowedTCPPorts = [
    8080 # zigbee2mqtt frontend
    8095 # music assistant web UI and login
    8123 # home assistant
  ];
  networking.firewall.allowedUDPPorts = [5540]; # matter operational
  environment.systemPackages = with pkgs; [git sqlite];
  system.stateVersion = "26.05";
}
