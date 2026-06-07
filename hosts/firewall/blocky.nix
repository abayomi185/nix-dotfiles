# Blocky — DNS ad blocking proxy behind Unbound.
#
# Architecture:
#   Clients → Unbound:53 → (internal?) → Dnsmasq:53053
#                        → (external?) → Blocky:5354 → upstream DNS
#
# Blocky filters via StevenBlack blocklist, then forwards clean queries
# to Cloudflare (1.1.1.1) and Quad9 (9.9.9.9).
# Prometheus metrics exposed on :4000/metrics.
# Bootstrap DNS — used by Blocky itself to resolve blocklist download URLs.
# Without this, Blocky can't download lists at startup (Blocky IS the DNS).
# These bypass Unbound and go direct to Cloudflare.
let
  bootstrapDns = "1.1.1.1";
in {
  services.blocky = {
    enable = true;

    settings = {
      ports = {
        # Listen on loopback only — Unbound is the only client.
        # Port 5354 avoids conflict with avahi (mDNS on 5353).
        dns = ["127.0.0.1:5354"];
        # HTTP for Prometheus metrics (loopback only; Prometheus scrapes locally).
        http = ["127.0.0.1:4000"];
      };

      upstreams.groups.default = [
        # Cloudflare
        "1.1.1.1"
        "1.0.0.1"
        # Quad9
        "9.9.9.9"
        "149.112.112.112"
      ];

      # Bootstrap DNS — Blocky uses this to resolve blocklist URLs at startup,
      # bypassing the normal upstream chain to avoid a chicken-and-egg problem.
      bootstrapDns = bootstrapDns;

      # Blocklists — StevenBlack unified hosts file (~84K entries).
      # Only hosts-compatible lists (domain → 0.0.0.0); not adblock syntax.
      blocking = {
        denylists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = ["ads"];
        loading.downloads = {
          timeout = "30s";
          attempts = 5;
        };
      };

      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };
  };
}
