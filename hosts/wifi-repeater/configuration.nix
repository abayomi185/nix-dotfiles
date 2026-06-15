# Pi 4 wifi-repeater — system config.
#
# Topology:
#   INTERNET → main router → eth0 (DHCP) → Pi → wlan0 (AWUS0360ACS, 2.4 GHz AP) → Tesla
#
# See ./README.md for SOPS secret setup and flashing instructions.
{
  config,
  inputs,
  lib,
  ...
}: {
  # ── Identity ───────────────────────────────────────────
  networking.hostName = "wifi-repeater";
  networking.domain = "internal.yomitosh.media";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "en_GB.UTF-8";
  console.keyMap = "uk";

  # ── Nix settings ───────────────────────────────────────
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # ── Wireless driver (AWUS0360ACS = RTL8811AU) ──────────
  # In-kernel rtw_8821au (mainline from 6.13, polished in 6.14)
  # covers the RTL8811AU (0bda:0811). Used in-kernel here because
  # pkgs.rtl8821au is broken on kernels ≥ 6.15 and morrownr has
  # deprecated the out-of-tree driver.
  # AP mode on rtw_8821au has open flakiness reports
  # (lwfinger/rtw88#323) — test on the bench before deploying.
  boot.kernelModules = ["rtw_8821au"];

  # Disable onboard WiFi/BT so hostapd has clean control of the USB radio.
  # Per morrownr/USB-WiFi AP guide: Pi 4 USB subsystem is shared 1200 mA budget;
  # AWUS0360ACS draws ~500 mA peak so it fits if nothing else is on USB.
  hardware.raspberry-pi.config.all = {
    dt-overlays = {
      disable-bt.enable = true;
      disable-wifi.enable = true;
    };
    base-dt-params = {
      "act_led_trigger" = {value = "none";};
      "pwr_led_trigger" = {value = "none";};
      "eth_led0" = {value = 4;};
      "eth_led1" = {value = 4;};
    };
  };

  # ── Networking ─────────────────────────────────────────
  # Match knode pattern: disable predictable names so eth0/wlan0 stick.
  networking.usePredictableInterfaceNames = lib.mkForce false;

  # Upstream: eth0 from main router DHCP.
  networking.useDHCP = false;
  networking.dhcpcd.enable = true;
  networking.interfaces.eth0.useDHCP = true;

  # Downstream: wlan0 (AWUS0360ACS) static 192.168.50.1/24.
  networking.interfaces.wlan0.ipv4.addresses = [
    {
      address = "192.168.50.1";
      prefixLength = 24;
    }
  ];

  # NAT: wlan0 clients → internet via eth0.
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = ["wlan0"];
  };

  # Firewall: SSH from anywhere; DNS/DHCP only on the AP subnet.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
    interfaces.wlan0 = {
      allowedTCPPorts = [53 67];
      allowedUDPPorts = [53 67];
    };
  };

  # mDNS so `wifi-repeater.local` resolves from the AP subnet.
  services.avahi.enable = true;

  # Output an uncompressed .img so Raspberry Pi Imager and balenaEtcher
  # can flash it directly. Trade-off: file is ~2 GB instead of ~600 MB.
  sdImage.compressImage = false;

  # NixOS 26.05+ uses the new typed hostapd module.
  # Passphrase comes from SOPS via `wpaPasswordFile`
  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      band = "2g";
      # channel = 0 enables ACS (Automatic Channel Selection): hostapd
      # scans all 2.4 GHz channels at boot and picks the cleanest one.
      channel = 0;
      countryCode = "GB";
      networks.wlan0 = {
        ssid = "Airport";
        authentication = {
          # WPA2-SHA256 is well-supported by the 8821au driver.
          # WPA3-SAE is the module default but is less stable on RTL8811AU.
          mode = "wpa2-sha256";
          wpaPasswordFile = config.sops.secrets."hostapd/passphrase".path;
        };
      };
    };
  };

  # ── dnsmasq (DHCP/DNS for AP clients) ──────────────────
  # Disable systemd-resolved stub listener; dnsmasq owns :53.
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      bind-interfaces = true;
      domain-needed = true;
      bogus-priv = true;
      dhcp-range = "192.168.50.10,192.168.50.200,255.255.255.0,12h";
      dhcp-option = [
        "3,192.168.50.1" # default gateway
        "6,192.168.50.1" # DNS server
      ];
      cache-size = 1000;
    };
  };

  # ── SSH ────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    openFirewall = false; # firewall rule above opens 22
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys =
    import ../shared/authorized-keys.nix {inherit inputs;};

  # ── SOPS ───────────────────────────────────────────────
  # Reads the hostapd passphrase from the local secrets file at
  # activation time. Replace the placeholder in ./secrets.enc.yaml
  # and encrypt it with `sops --encrypt --in-place` before flashing.
  # The Pi needs /root/.ssh/id_ed25519 copied to it post-flash
  # (same dance as the knode hosts). See README.
  sops = {
    age.sshKeyPaths = ["/root/.ssh/id_ed25519"];
    defaultSopsFile = ./secrets.enc.yaml;
    secrets."hostapd/passphrase" = {
      owner = "root";
      group = "root";
      mode = "0600";
    };
  };

  # ── System state ───────────────────────────────────────
  system.stateVersion = "26.05";
}
