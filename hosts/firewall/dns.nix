# DNS configuration: Unbound (recursive resolver) + Dnsmasq (local authority)
#
# Architecture (matching OPNsense split-DNS setup):
#   Clients -> Unbound (port 53) -> Internet (recursive)
#                                -> Dnsmasq (port 53053) for local zones
#   Dnsmasq handles: internal.yomitosh.media, reverse PTR zones, DHCP hostnames
{
  config,
  lib,
  pkgs,
  ...
}: {
  # ── Unbound: Recursive DNS resolver on port 53 ─────────────────────────
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = ["0.0.0.0" "::0"];
        port = 53;

        # Access control - allow all LAN subnets
        access-control = [
          "127.0.0.0/8 allow"
          "10.1.1.0/24 allow"
          "10.1.5.0/24 allow"
          "10.1.10.0/24 allow"
          "10.1.50.0/24 allow"
          "10.13.13.0/24 allow"
          "::1/128 allow"
        ];

        # Privacy and security
        hide-identity = true;
        hide-version = true;
        aggressive-nsec = true;

        # Private addresses (matching OPNsense Unbound config)
        private-address = [
          "0.0.0.0/8"
          "10.0.0.0/8"
          "100.64.0.0/10"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "192.0.2.0/24"
          "192.168.0.0/16"
          "198.18.0.0/15"
          "198.51.100.0/24"
          "203.0.113.0/24"
          "233.252.0.0/24"
          "::1/128"
          "2001:db8::/32"
          "fc00::/8"
          "fd00::/8"
          "fe80::/10"
        ];

        # Allow private addresses in responses for local domains
        private-domain = [
          "internal.yomitosh.media"
          "local.yomitosh.media"
          "cluster.internal.yomitosh.media"
        ];

        # Insecure domains (no DNSSEC validation for local)
        domain-insecure = [
          "internal.yomitosh.media"
          "local.yomitosh.media"
          "cluster.internal.yomitosh.media"
        ];

        # Local zone: transparent (pass through to forwarding if no local data)
        local-zone = [
          ''"internal.yomitosh.media." transparent''
          ''"cluster.internal.yomitosh.media." transparent''
          ''"local.yomitosh.media." redirect''
        ];

        # ── Host overrides (from OPNsense Unbound host entries) ────────
        local-data = [
          ''"pve-firewall.internal.yomitosh.media. IN A 10.1.5.11"''
          ''"pve.internal.yomitosh.media. IN A 10.1.5.12"''
          ''"knode1.cluster.internal.yomitosh.media. IN A 10.0.7.41"''
          ''"knode2.cluster.internal.yomitosh.media. IN A 10.0.7.42"''
          ''"knode3.cluster.internal.yomitosh.media. IN A 10.0.7.43"''
          ''"knode4.cluster.internal.yomitosh.media. IN A 10.0.7.44"''
          # Wildcard for *.local.yomitosh.media -> K8s load balancer
          ''"local.yomitosh.media. IN A 10.1.5.40"''
        ];
      };

      # ── Forward zones to Dnsmasq (port 53053) for local resolution ───
      forward-zone = [
        {
          name = "internal.yomitosh.media.";
          forward-addr = "127.0.0.1@53053";
        }
        {
          name = "10.1.10.in-addr.arpa.";
          forward-addr = "127.0.0.1@53053";
        }
        {
          name = "50.1.10.in-addr.arpa.";
          forward-addr = "127.0.0.1@53053";
        }
        {
          name = "1.1.10.in-addr.arpa.";
          forward-addr = "127.0.0.1@53053";
        }
        {
          name = "5.1.10.in-addr.arpa.";
          forward-addr = "127.0.0.1@53053";
        }
      ];
    };
  };
}
