# Prometheus monitoring stack: exporters + Prometheus server + Grafana
#
# Exporters (firewall metrics exposed to any Prometheus scraper):
#   - node_exporter (netdev/netstat/textfile) → :9100
#   - unbound_exporter (DNS query stats)      → :9167
#   - dnsmasq_exporter (DHCP/lease stats)     → :9153
#
# Prometheus scrapes the local exporters and serves at :9090.
# Grafana dashboards at :3000 (default admin:admin).
{pkgs, ...}: {
  # ── Exporters ───────────────────────────────────────────────────────────
  services.prometheus.exporters = {
    # System / network interface metrics (bandwidth, drops, errors).
    node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "netdev"
        "netstat"
        "textfile"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
      ];
      # Listen on all interfaces so K8s cluster (sfp1.5) can scrape later.
      listenAddress = "0.0.0.0";
    };

    # Unbound recursive resolver statistics (queries, cache, recursion).
    unbound = {
      enable = true;
      port = 9167;
      listenAddress = "0.0.0.0";
    };

    # Dnsmasq DHCP / DNS lease metrics.
    dnsmasq = {
      enable = true;
      port = 9153;
      listenAddress = "0.0.0.0";
      leasesPath = "/var/lib/dnsmasq/dnsmasq.leases";
    };
  };

  # ── Prometheus server ─────────────────────────────────────────────────
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "0.0.0.0";

    scrapeConfigs = [
      {
        job_name = "firewall-node";
        scrape_interval = "15s";
        static_configs = [{targets = ["localhost:9100"];}];
      }
      {
        job_name = "firewall-unbound";
        scrape_interval = "15s";
        static_configs = [{targets = ["localhost:9167"];}];
      }
      {
        job_name = "firewall-dnsmasq";
        scrape_interval = "15s";
        static_configs = [{targets = ["localhost:9153"];}];
      }
      {
        job_name = "firewall-blocky";
        scrape_interval = "15s";
        static_configs = [{targets = ["localhost:4000"];}];
      }
    ];

    # 90 days of data at ~15 s scrape interval = ~200 MiB for these targets.
    retentionTime = "90d";
  };

  # ── Grafana ────────────────────────────────────────────────────────────
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 3000;
        http_addr = "0.0.0.0";
      };
      security = {
        admin_user = "admin";
        admin_password = "admin";
      };
    };

    # Provision Prometheus as the default datasource and dashboard.
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "prometheus";
          access = "proxy";
          url = "http://localhost:9090";
          isDefault = true;
        }
      ];

      dashboards.settings.providers = [
        {
          name = "firewall";
          options.path = ./dashboards;
        }
      ];
    };
  };

  # ── DHCP lease metrics collector ───────────────────────────────────────
  # Parses dnsmasq leases and writes per-hostname/IP Prometheus metrics
  # so Grafana can display a hostname→IP table.
  systemd.services.dhcp-lease-metrics = {
    description = "Write dnsmasq DHCP lease metrics for node_exporter textfile collector";
    path = with pkgs; [coreutils gawk];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "dhcp-lease-metrics" ''
        set -e
        out="/var/lib/node_exporter/textfile_collector"
        tmp="$out/dhcp_leases.prom.tmp"
        mkdir -p "$out"
        echo '# HELP dnsmasq_dhcp_lease_info Per-lease hostname/IP mapping (1 = active).' > "$tmp"
        echo '# TYPE dnsmasq_dhcp_lease_info gauge' >> "$tmp"
        awk 'NF { printf "dnsmasq_dhcp_lease_info{hostname=\"%s\",ip=\"%s\",mac=\"%s\"} 1\n", $4, $3, $2 }' \
          /var/lib/dnsmasq/dnsmasq.leases >> "$tmp"
        mv "$tmp" "$out/dhcp_leases.prom"
      '';
    };
  };

  systemd.timers.dhcp-lease-metrics = {
    description = "Collect DHCP lease metrics every 60s";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "60s";
      AccuracySec = "5s";
    };
  };
}
