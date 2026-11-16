{
  inputs,
  modulesPath,
  pkgs,
  ...
}: let
  authorizedKeys = import ../shared/authorized-keys.nix {inherit inputs;};
  # SLZB-MR2 (YHLD-SLZB1): EFR32MG21 Thread RCP and CC2652P Zigbee coordinator.
  slzb = "slzb-mr2.internal.yomitosh.media";
  otbrRadio = "/run/otbr-radio";
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
      "wyoming"
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
    };
  };

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

  # ── Thread / Matter ─────────────────────────────────────
  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = ["ens18"];
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

  services.matter-server.enable = true;

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
      "builtin"
      "chromecast"
      "hass"
      "hass_players"
      "radiobrowser"
      "spotify"
    ];
  };

  services.wyoming.faster-whisper.servers.en = {
    enable = true;
    language = "en";
    uri = "tcp://127.0.0.1:10300";
  };

  networking.firewall.allowedTCPPorts = [
    8080 # zigbee2mqtt frontend
    8123 # home assistant
  ];
  environment.systemPackages = with pkgs; [git sqlite];
  system.stateVersion = "26.05";
}
