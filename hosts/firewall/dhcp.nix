# DHCP + local DNS authority — Dnsmasq.
#
# Dnsmasq answers DNS on :53053 (Unbound forwards the local zones here, see
# dns.nix) and serves DHCP for every LAN. DHCP reservations double as static
# DNS records: each `mac,host,ip` makes `host.internal.yomitosh.media` resolve
# to `ip` regardless of lease state — this is what k3s' serverAddr
# (`knodeN.internal.yomitosh.media:6443`) depends on.
#
# Migrated from OPNsense Dnsmasq configuration.
{...}: {
  services.dnsmasq = {
    enable = true;
    settings = {
      # DNS on 53053 — Unbound owns :53 and forwards local zones to us.
      port = 53053;
      interface = ["br-phy" "br-main" "br-iot" "sfp1.5"];

      # Self-contained local authority: never read /etc/resolv.conf, never
      # forward upstream (Unbound handles recursion).
      no-resolv = true;
      local = "/internal.yomitosh.media/";
      domain = "internal.yomitosh.media";
      expand-hosts = true;
      dhcp-authoritative = true;

      # ── DHCP ranges (per LAN) ──────────────────────────────────────────
      dhcp-range = [
        "interface:br-main,10.1.10.100,10.1.10.250,255.255.255.0,4h" # VLAN_MAIN
        "interface:br-iot,10.1.50.100,10.1.50.250,255.255.255.0,6h" # VLAN_IOT
        "interface:br-phy,10.1.1.100,10.1.1.250,255.255.255.0,4h" # PHY bridge
        "interface:sfp1.5,10.1.5.100,10.1.5.250,255.255.255.0,4h" # VLAN_PHY/infra
      ];

      # ── Per-LAN gateway + DNS (this firewall) ──────────────────────────
      dhcp-option = [
        "interface:br-main,option:router,10.1.10.1"
        "interface:br-main,option:dns-server,10.1.10.1"
        "interface:br-iot,option:router,10.1.50.1"
        "interface:br-iot,option:dns-server,10.1.50.1"
        "interface:br-phy,option:router,10.1.1.1"
        "interface:br-phy,option:dns-server,10.1.1.1"
        "interface:sfp1.5,option:router,10.1.5.1"
        "interface:sfp1.5,option:dns-server,10.1.5.1"
      ];

      # ── Static reservations (mac,host,ip) — from OPNsense ──────────────
      dhcp-host = [
        # Infrastructure / VLAN 5 (10.1.5.0/24)
        "bc:24:11:78:dc:ab,kloadbalancer,10.1.5.40"
        "bc:24:11:24:10:3b,knode1,10.1.5.71"
        "bc:24:11:34:e2:12,knode2,10.1.5.72"
        "bc:24:11:3b:26:f1,knode3,10.1.5.73"
        "bc:24:11:8b:0c:40,knode4,10.1.5.74"
        # IoT / VLAN 50 (10.1.50.0/24)
        "fc:ee:28:03:6c:d5,k1c,10.1.50.83"
        "80:9d:65:5e:3a:34,x2d,10.1.50.114"
      ];

      # ── Static DNS records (no DHCP lease needed) ─────────────────────
      "host-record" = [
        "pve-firewall.internal.yomitosh.media,10.1.5.11"
        "pve.internal.yomitosh.media,10.1.5.12"
      ];

      no-hosts = false;
      quiet-dhcp = true;
    };
  };
}
