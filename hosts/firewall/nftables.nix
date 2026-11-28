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
          elements = { "br-native", "vlan-infra", "br-main", "vlan-guest", "br-iot" }
        }

        # Subnets trusted WireGuard peers may reach.
        set wg_allowed_dst {
          type ipv4_addr
          flags interval
          elements = { 10.1.5.0/24, 10.1.10.0/24, 10.1.50.0/24 }
        }

        # WireGuard peers trusted like the main LAN: y-iphone, mbp14, mstdo.
        set wg_trusted {
          type ipv4_addr
          elements = { 10.13.13.7, 10.13.13.14, 10.13.13.15 }
        }

        # The VPS (10.13.13.1) is internet-facing, so it only gets what its
        # k3s agent needs. Other peers get nothing behind the firewall.
        set knodes {
          type ipv4_addr
          flags interval
          elements = { 10.1.5.71-10.1.5.74 }
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

          # mDNS reflector ingress (VLAN_MAIN + infra VLAN).
          iifname { "br-main", "vlan-infra" } udp dport 5353 accept

          # SSH management from the main LAN and the infra VLAN only.
          iifname { "br-main", "vlan-infra" } tcp dport 22 accept

          # Prometheus exporters. Infra only: the dnsmasq lease metrics list
          # every device on every VLAN.
          iifname "vlan-infra" tcp dport { 9100, 9167, 9153 } accept

          # Prometheus, Grafana & Blocky web UIs (admin access only).
          iifname { "br-main", "vlan-infra" } tcp dport { 9090, 3000, 4000 } accept

          # UniFi OS Server UI (admin access only).
          iifname { "br-main", "vlan-infra" } tcp dport 11443 accept

          # UniFi device adoption, provisioning, STUN, and discovery.
          iifname "vlan-infra" tcp dport 8080 accept
          iifname "vlan-infra" udp dport { 3478, 10001 } accept

          # Direct UniFi Network UI/API and mobile speed test.
          iifname { "br-main", "vlan-infra" } tcp dport 8443 accept
          iifname "br-main" tcp dport 6789 accept

          # Guest captive portal redirection.
          iifname "vlan-guest" tcp dport { 8843, 8880 } accept

          # WireGuard: trusted peers get everything; the VPS gets DNS only
          # (its dnsmasq forwards internal zones here).
          iifname "wg0" ip saddr @wg_trusted accept
          iifname "wg0" ip saddr 10.13.13.1 meta l4proto { tcp, udp } th dport 53 accept

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
          iifname { "br-native", "vlan-infra", "br-main" } accept

          # Guests: internet only; no access to other LANs.
          iifname "vlan-guest" oifname "wan0" accept

          # IoT: internet only, plus same-segment hairpin; no lateral access to
          # other LANs (OPNsense "IoT net -> !RFC1918" + "IoT -> IoT").
          iifname "br-iot" oifname "wan0" accept
          iifname "br-iot" oifname "br-iot" accept

          # WireGuard: trusted peers reach the internal subnets and the internet.
          iifname "wg0" ip saddr @wg_trusted ip daddr @wg_allowed_dst accept
          iifname "wg0" ip saddr @wg_trusted oifname "wan0" accept

          # VPS k3s agent: API server, flannel VXLAN, and NFS (traefik ACME).
          # Knode-initiated traffic (kubelet 10250) is allowed via vlan-infra.
          iifname "wg0" ip saddr 10.13.13.1 ip daddr @knodes tcp dport 6443 accept
          iifname "wg0" ip saddr 10.13.13.1 ip daddr @knodes udp dport 8472 accept
          iifname "wg0" ip saddr 10.13.13.1 ip daddr 10.1.5.124 tcp dport 2049 accept

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
