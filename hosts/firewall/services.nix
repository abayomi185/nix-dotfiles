# Additional services
# mDNS repeater, SSH, QEMU guest agent, NTP
{
  config,
  lib,
  pkgs,
  ...
}: {
  # ── QEMU Guest Agent (matching OPNsense os-qemu-guest-agent) ───────────
  services.qemuGuest.enable = true;

  # ── SSH ─────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
    # Firewall rules restrict SSH to br-main only (see nftables.nix)
  };

  # ── mDNS Repeater ──────────────────────────────────────────────────────
  # OPNsense had mdns-repeater between VLAN_MAIN and VLAN_PHY.
  # Avahi reflector mode achieves the same by reflecting mDNS across interfaces.
  services.avahi = {
    enable = true;
    reflector = true;
    allowInterfaces = ["br-main" "sfp1-v5"];
    # Don't publish the firewall's own services
    publish = {
      enable = false;
    };
  };

  # ── NTP ─────────────────────────────────────────────────────────────────
  # Use chrony for better drift handling on VMs
  services.chrony = {
    enable = true;
    servers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];
    # Allow NTP queries from LAN clients (IoT VLAN requests NTP from firewall)
    extraConfig = ''
      allow 10.1.0.0/16
    '';
  };
  # Disable default timesyncd since we use chrony
  services.timesyncd.enable = false;
}
