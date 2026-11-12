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
    hostName = "home-assistant";
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
    extraComponents = [
      "analytics"
      "apple_tv"
      "backup"
      "default_config"
      "esphome"
      "go2rtc"
      "homekit"
      "isal"
      "matter"
      "met"
      "mobile_app"
      "mqtt"
      "music_assistant"
      "otbr"
      "prometheus"
      "speedtestdotnet"
      "spotify"
      "sun"
      "thread"
      "vesync"
      "wyoming"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      octopus_energy
    ];
    config = {
      default_config = {};
      prometheus = {};
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
      # NOTE: confirm against the add-on's /config/zigbee2mqtt/configuration.yaml.
      serial = {
        port = "tcp://${slzb}:7638";
        adapter = "zstack";
      };
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

  services.node-red = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [
    8080 # zigbee2mqtt frontend
    8123 # home assistant
  ];
  environment.systemPackages = with pkgs; [git sqlite];
  system.stateVersion = "26.05";
}
