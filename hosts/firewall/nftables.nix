# nftables firewall rules
# Migrated from OPNsense pf rules
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Disable the default NixOS iptables-based firewall; we use raw nftables
  networking.firewall.enable = false;

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        # ── Sets for readability ──────────────────────────────────────
        set lan_subnets {
          type ipv4_addr
          flags interval
          elements = {
            10.1.1.0/24,
            10.1.5.0/24,
            10.1.10.0/24,
            10.1.50.0/24
          }
        }

        set wg_allowed_dst {
          type ipv4_addr
          flags interval
          elements = {
            10.1.5.0/24,
            10.1.10.0/24,
            10.1.50.0/24
          }
        }

        set lan_ifaces {
          type ifname
          elements = { "br-phy", "br-main", "br-iot", "sfp1-v5" }
        }

        # ── Input chain (traffic TO the firewall itself) ──────────────
        chain input {
          type filter hook input priority filter; policy drop;

          # Established/related traffic
          ct state established,related accept

          # Drop invalid
          ct state invalid drop

          # Loopback
          iifname "lo" accept

          # ICMP / ICMPv6
          ip protocol icmp accept
          ip6 nexthdr icmpv6 accept

          # DHCP client on WAN
          iifname "wan0" udp sport 67 udp dport 68 accept

          # DNS from LAN interfaces (Unbound on 53)
          iifname @lan_ifaces udp dport 53 accept
          iifname @lan_ifaces tcp dport 53 accept

          # Dnsmasq on localhost (port 53053)
          iifname "lo" udp dport 53053 accept
          iifname "lo" tcp dport 53053 accept

          # DHCP server (requests from clients)
          iifname @lan_ifaces udp dport 67 accept

          # NTP from IoT (OPNsense allowed UDP 123 from VLAN_IOT to self)
          iifname "br-iot" udp dport 123 accept

          # SSH from VLAN_MAIN only (matching OPNsense SSH interface restriction)
          iifname "br-main" tcp dport 22 accept

          # WireGuard on WAN
          iifname "wan0" udp dport 51820 accept

          # WireGuard peers accessing firewall services (logged)
          iifname "wg0" ip saddr 10.13.13.0/24 log prefix "wg-in: " accept

          # mDNS from VLAN_MAIN and VLAN_PHY (for avahi reflector)
          iifname { "br-main", "sfp1-v5" } udp dport 5353 accept

          # Log dropped packets (rate limited)
          log prefix "nft-input-drop: " limit rate 5/minute counter drop
        }

        # ── Forward chain (traffic THROUGH the firewall) ──────────────
        chain forward {
          type filter hook forward priority filter; policy drop;

          # Established/related
          ct state established,related accept

          # Drop invalid
          ct state invalid drop

          # MSS clamping for WireGuard traffic
          # (matching OPNsense scrub max-mss 1380 on wireguard interface)
          iifname "wg0" tcp flags syn tcp option maxseg size set 1380
          oifname "wg0" tcp flags syn tcp option maxseg size set 1380

          # ── BRIDGE_PHY_LAN (br-phy): pass any to any ───────────────
          iifname "br-phy" accept

          # ── VLAN_MAIN (br-main): pass to any ───────────────────────
          iifname "br-main" accept

          # ── VLAN_PHY / Infrastructure (sfp1-v5): pass to any ────────
          iifname "sfp1-v5" accept

          # ── VLAN_IOT (br-iot): restricted ───────────────────────────
          # IoT to IoT (same subnet)
          iifname "br-iot" oifname "br-iot" accept
          # IoT to internet (WAN) but NOT to other LANs
          iifname "br-iot" oifname "wan0" accept
          # IoT to DNS on firewall is handled by input chain

          # ── WireGuard: to IoT, Main, PHY networks (logged) ─────────
          iifname "wg0" ip daddr @wg_allowed_dst log prefix "wg-fwd: " accept
          # WireGuard to WAN (internet via tunnel)
          iifname "wg0" oifname "wan0" accept

          # Log dropped packets
          log prefix "nft-fwd-drop: " limit rate 5/minute counter drop
        }

        # ── Output chain (traffic FROM the firewall itself) ───────────
        chain output {
          type filter hook output priority filter; policy accept;
        }
      }

      # ── NAT table ──────────────────────────────────────────────────────
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          # Masquerade all internal traffic going out WAN
          oifname "wan0" masquerade
        }
      }
    '';
  };
}
