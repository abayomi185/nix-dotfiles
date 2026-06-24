# nftables firewall — migrated from OPNsense pf rules.
#
# Policy: input/forward default-drop. Intra-bridge (same subnet) traffic is
# L2-switched and never reaches these IP hooks (br_netfilter is not loaded),
# so only inter-subnet routed traffic is filtered here.
{...}: {
  # Replace the iptables-based NixOS firewall with a hand-written ruleset.
  networking.firewall.enable = false;

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        # ── Reusable sets ─────────────────────────────────────────────────
        # LAN-facing L3 interfaces (the firewall's own service surface).
        set lan_ifaces {
          type ifname
          elements = { "br-phy", "br-main", "br-iot", "sfp1.5" }
        }

        # Subnets a WireGuard peer (the VPS) is allowed to reach.
        set wg_allowed_dst {
          type ipv4_addr
          flags interval
          elements = { 10.1.5.0/24, 10.1.10.0/24, 10.1.50.0/24 }
        }

        # ── Input: traffic TO the firewall itself ─────────────────────────
        chain input {
          type filter hook input priority filter; policy drop;

          ct state established,related accept
          ct state invalid drop
          iifname "lo" accept

          # ICMP / ICMPv6 (incl. neighbour discovery).
          ip protocol icmp accept
          ip6 nexthdr icmpv6 accept

          # WAN: accept DHCP client replies only; everything else is dropped.
          iifname "wan0" udp sport 67 udp dport 68 accept

          # DNS resolver (Unbound :53) for every LAN.
          iifname @lan_ifaces udp dport 53 accept
          iifname @lan_ifaces tcp dport 53 accept

          # DHCP server requests from LAN clients.
          iifname @lan_ifaces udp dport 67 accept

          # NTP for IoT (OPNsense allowed UDP 123 from VLAN_IOT to self).
          iifname "br-iot" udp dport 123 accept

          # mDNS reflector ingress (main, infra, and IoT VLANs).
          iifname { "br-main", "br-iot", "sfp1.5" } udp dport 5353 accept

          # SSH management from the main LAN and the infra VLAN only.
          iifname { "br-main", "sfp1.5" } tcp dport 22 accept

          # Prometheus exporters (reachable from any LAN for future K8s scraping).
          iifname @lan_ifaces tcp dport { 9100, 9167, 9153 } accept

          # Prometheus, Grafana & Blocky web UIs (admin access only).
          iifname { "br-main", "sfp1.5" } tcp dport { 9090, 3000, 4000 } accept

          # WireGuard peer (VPS, 10.13.13.1) reaching firewall services.
          iifname "wg0" ip saddr 10.13.13.0/24 accept

          log prefix "nft-input-drop: " limit rate 5/minute counter drop
        }

        # ── Forward: routed traffic THROUGH the firewall ──────────────────
        chain forward {
          type filter hook forward priority filter; policy drop;

          ct state established,related accept
          ct state invalid drop

          # Clamp MSS on WireGuard path (OPNsense scrub max-mss 1380).
          iifname "wg0" tcp flags syn / syn,rst tcp option maxseg size set 1380
          oifname "wg0" tcp flags syn / syn,rst tcp option maxseg size set 1380

          # Trusted LANs: unrestricted egress (OPNsense "net -> any" rules).
          iifname { "br-phy", "br-main", "sfp1.5" } accept

          # IoT: internet only, plus same-segment hairpin; no lateral access to
          # other LANs (OPNsense "IoT net -> !RFC1918" + "IoT -> IoT").
          iifname "br-iot" oifname "wan0" accept
          iifname "br-iot" oifname "br-iot" accept

          # WireGuard: reach the allowed internal subnets and the internet.
          iifname "wg0" ip daddr @wg_allowed_dst accept
          iifname "wg0" oifname "wan0" accept

          log prefix "nft-fwd-drop: " limit rate 5/minute counter drop
        }

        chain output {
          type filter hook output priority filter; policy accept;
        }
      }

      # ── Source NAT: masquerade all egress out WAN ───────────────────────
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          oifname "wan0" masquerade
        }
      }
    '';
  };
}
