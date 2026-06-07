# DNS configuration: Unbound (recursive resolver) + Dnsmasq (local authority) + Blocky (ad blocking)
#
# Architecture:
#   Clients → Unbound (port 53) → internal.yomitosh.media? → Dnsmasq:53053
#                               → cluster/local zones?      → Unbound local-data
#                               → everything else?          → Blocky:5354 → upstream
{...}: {
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

        # Unbound's compiled-in default blocks queries to localhost
        # (do-not-query-localhost: yes), which silently breaks forwarding to
        # dnsmasq on 127.0.0.1:53053. Allow it so the split-DNS forward works.
        do-not-query-localhost = false;

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
          ''"cluster.internal.yomitosh.media." transparent''
          ''"local.yomitosh.media." redirect''
        ];

        # ── Host overrides (from OPNsense Unbound host entries) ────────
        local-data = [
          ''"knode1.cluster.internal.yomitosh.media. IN A 10.0.7.41"''
          ''"knode2.cluster.internal.yomitosh.media. IN A 10.0.7.42"''
          ''"knode3.cluster.internal.yomitosh.media. IN A 10.0.7.43"''
          ''"network-share.cluster.internal.yomitosh.media. IN A 10.0.7.202"''
          # Wildcard for *.local.yomitosh.media -> K8s load balancer
          ''"local.yomitosh.media. IN A 10.1.5.40"''
          # Override /etc/hosts loopback mapping so clients resolve the real IP.
          ''"firewall.internal.yomitosh.media. IN A 10.1.10.1"''
        ];
      };

      # ── Remote control socket for prometheus-unbound-exporter ──────────
      # The exporter connects via tcp://127.0.0.1:8953 to read stats.
      # control-enable = false by default (hardened); enable explicitly.
      remote-control = {
        control-enable = true;
      };

      # ── Forward zones ─────────────────────────────────────────────────
      # More-specific zones are tried first. Local zones → Dnsmasq;
      # catch-all (".") → Blocky (ad filtering before upstream recursion).
      forward-zone = [
        # Local DNS authority — DHCP hostnames, host-record entries.
        {
          name = "internal.yomitosh.media.";
          forward-addr = "127.0.0.1@53053";
          forward-first = "yes";
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
        # Blocky ad blocker — filters all external DNS before upstream.
        {
          name = ".";
          forward-addr = "127.0.0.1@5354";
        }
      ];
    };
  };
}
