# DHCP and local DNS authority via Dnsmasq
# Dnsmasq runs on port 53053 for DNS (forwarded from Unbound) and handles DHCP
#
# Migrated from OPNsense Dnsmasq configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.dnsmasq = {
    enable = true;
    settings = {
      # ── General ─────────────────────────────────────────────────────
      # Listen on port 53053 for DNS (Unbound forwards local zones here)
      port = 53053;

      # Only listen on LAN-facing interfaces for DNS
      # (DHCP will also use these interfaces)
      interface = ["br-phy" "br-main" "br-iot" "sfp1-v5"];

      # Don't read /etc/resolv.conf (matching OPNsense no-resolv)
      no-resolv = true;

      # Don't send queries upstream - we only answer what we know locally
      # Unbound handles recursion
      local = "/internal.yomitosh.media/";

      # Domain for DHCP hostnames
      domain = "internal.yomitosh.media";

      # Always return fully qualified domain names for DHCP hosts
      expand-hosts = true;

      # Authoritative mode (matching OPNsense setting)
      dhcp-authoritative = true;

      # ── DHCP Ranges ────────────────────────────────────────────────
      dhcp-range = [
        # VLAN_MAIN (br-main) - 10.1.10.0/24, lease 4h
        "interface:br-main,10.1.10.100,10.1.10.250,255.255.255.0,4h"
        # VLAN_IOT (br-iot) - 10.1.50.0/24, lease 6h
        "interface:br-iot,10.1.50.100,10.1.50.250,255.255.255.0,6h"
        # PHY_LAN (br-phy) - 10.1.1.0/24, lease 4h
        "interface:br-phy,10.1.1.100,10.1.1.250,255.255.255.0,4h"
        # VLAN_PHY (sfp1-v5) - 10.1.5.0/24, lease 4h
        "interface:sfp1-v5,10.1.5.100,10.1.5.250,255.255.255.0,4h"
      ];

      # ── DHCP Options ───────────────────────────────────────────────
      # Set default gateway (this firewall) and DNS per interface
      dhcp-option = [
        # br-main: gateway + DNS
        "interface:br-main,option:router,10.1.10.1"
        "interface:br-main,option:dns-server,10.1.10.1"
        # br-iot: gateway + DNS
        "interface:br-iot,option:router,10.1.50.1"
        "interface:br-iot,option:dns-server,10.1.50.1"
        # br-phy: gateway + DNS
        "interface:br-phy,option:router,10.1.1.1"
        "interface:br-phy,option:dns-server,10.1.1.1"
        # sfp1-v5: gateway + DNS
        "interface:sfp1-v5,option:router,10.1.5.1"
        "interface:sfp1-v5,option:dns-server,10.1.5.1"
      ];

      # ── Static DHCP Leases ─────────────────────────────────────────
      dhcp-host = [
        # k1c Klipper printer (IoT VLAN)
        "fc:ee:28:03:6c:d5,k1c,10.1.50.83"
        # Kubernetes load balancer (Infrastructure VLAN)
        "bc:24:11:78:dc:ab,kloadbalancer,10.1.5.40"
      ];

      # ── Logging ─────────────────────────────────────────────────────
      # Quiet DHCP logging (can enable for debugging)
      quiet-dhcp = true;

      # Don't use /etc/hosts
      no-hosts = false;
    };
  };
}
