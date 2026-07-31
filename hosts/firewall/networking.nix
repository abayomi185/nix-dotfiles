# Networking — systemd-networkd (router: interfaces, bridges, VLANs, addressing)
#
# Physical interfaces retain connector-oriented names. Logical L3 interfaces
# use <type>-<role>: br-* for bridged networks and vlan-* for directly routed
# VLANs. Internal VLAN bridge members keep the canonical <port>.<id> form.
#
#   Proxmox virtio NIC   role                         membership
#   ──────────────────   ──────────────────────────   ─────────────────────────
#   net0  -> wan0        WAN                          default route, NAT egress
#   net1  -> lan1        copper trunk                 br-native + VLAN 10/20/50
#   net2  -> lan2        copper access                br-native
#   net3  -> lan3        Game Box access              br-main
#   net4  -> sfp0        Mac Studio access            br-main
#   net5  -> sfp1        SFP trunk                    br-native + VLAN 5/10/50
#
#   logical interface    subnet           gateway      network role
#   ─────────────────   ──────────────   ──────────   ───────────────────
#   br-native            10.1.1.0/24      10.1.1.1     untagged/native
#   vlan-infra           10.1.5.0/24      10.1.5.1     infrastructure
#   br-main              10.1.10.0/24     10.1.10.1    trusted clients
#   vlan-guest           10.1.20.0/24     10.1.20.1    guests
#   br-iot               10.1.50.0/24     10.1.50.1    IoT
#
# The cluster network (10.0.7.0/24) is a Proxmox-internal bridge shared directly
# by the k8s nodes; the firewall has no interface on it and does not route it.
{...}: let
  # ── Interface name pinning ───────────────────────────────────────────────
  # Assign these exact MACs to net0..net5 in the Proxmox VM config, then they are
  # deterministic from first boot. Until filled in, naming fails loudly (router
  # will not come up) rather than silently mis-ordering NICs — see README.md.
  # TODO(switchover): replace the placeholder MACs with the VM's real ones.
  macs = {
    wan0 = "BC:24:11:51:30:B7"; # net0 / vtnet0
    lan1 = "BC:24:11:B4:EF:0D"; # net1 / vtnet1
    lan2 = "BC:24:11:CC:64:55"; # net2 / vtnet2
    lan3 = "BC:24:11:66:B5:B9"; # net3 / vtnet3
    sfp0 = "BC:24:11:37:82:FC"; # net4 / vtnet4
    sfp1 = "BC:24:11:96:2E:53"; # net5 / vtnet5
  };

  mkLink = name: mac: {
    matchConfig.MACAddress = mac;
    matchConfig.Type = "ether";
    linkConfig.Name = name;
  };

  bridge = name: {
    netdevConfig = {
      Name = name;
      Kind = "bridge";
    };
  };
  vlan = name: id: {
    netdevConfig = {
      Name = name;
      Kind = "vlan";
    };
    vlanConfig.Id = id;
  };
in {
  # ── Routing / hardening sysctls ──────────────────────────────────────────
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    # A router neither honours nor emits ICMP redirects.
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };
  # br_netfilter is deliberately NOT loaded: intra-bridge (L2-switched) frames
  # must bypass the nftables ip/inet forward hook. Only routed traffic between
  # subnets is filtered. This mirrors OPNsense's net.link.bridge.pfil_member=0.

  networking = {
    hostName = "firewall";
    domain = "internal.yomitosh.media";
    useDHCP = false;
    # The host resolves through its own Unbound (see dns.nix); ignore WAN DNS.
    nameservers = ["127.0.0.1" "::1"];
  };

  services.resolved.enable = false;

  systemd.network = {
    enable = true;

    # ── Name the 6 virtio NICs by MAC (.link) ──────────────────────────────
    links = {
      "10-wan0" = mkLink "wan0" macs.wan0;
      "10-lan1" = mkLink "lan1" macs.lan1;
      "10-lan2" = mkLink "lan2" macs.lan2;
      "10-lan3" = mkLink "lan3" macs.lan3;
      "10-sfp0" = mkLink "sfp0" macs.sfp0;
      "10-sfp1" = mkLink "sfp1" macs.sfp1;
    };

    # ── Bridges + VLAN sub-interfaces (.netdev) ────────────────────────────
    netdevs = {
      "20-br-native" = bridge "br-native";
      "20-br-main" = bridge "br-main";
      "20-br-iot" = bridge "br-iot";
      "30-vlan-infra" = vlan "vlan-infra" 5;
      "30-sfp1.10" = vlan "sfp1.10" 10;
      "30-sfp1.50" = vlan "sfp1.50" 50;
      "30-lan1.10" = vlan "lan1.10" 10;
      "30-vlan-guest" = vlan "vlan-guest" 20;
      "30-lan1.50" = vlan "lan1.50" 50;
    };

    # ── Addressing / membership (.network) ─────────────────────────────────
    networks = {
      # WAN uplink — DHCP, source of the default route. Ignore upstream DNS.
      "40-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.UseDNS = false;
        linkConfig.RequiredForOnline = "routable";
      };

      # Trunk: lan1 — untagged to br-native, tagged VLANs split to netdevs.
      "40-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig.Bridge = "br-native";
        vlan = ["lan1.10" "vlan-guest" "lan1.50"];
        linkConfig.RequiredForOnline = false;
      };
      # Trunk: sfp1 — untagged to br-native, tagged VLANs split to netdevs.
      "40-sfp1" = {
        matchConfig.Name = "sfp1";
        networkConfig.Bridge = "br-native";
        vlan = ["vlan-infra" "sfp1.10" "sfp1.50"];
        linkConfig.RequiredForOnline = false;
      };
      # Plain untagged bridge members.
      "40-lan2" = {
        matchConfig.Name = "lan2";
        networkConfig.Bridge = "br-native";
        linkConfig.RequiredForOnline = false;
      };
      "40-lan3" = {
        matchConfig.Name = "lan3";
        networkConfig.Bridge = "br-main";
        linkConfig.RequiredForOnline = false;
      };
      "40-sfp0" = {
        matchConfig.Name = "sfp0";
        networkConfig.Bridge = "br-main";
        linkConfig.RequiredForOnline = false;
      };

      # Directly routed VLANs use role names; bridge members use port + VLAN ID.
      "45-vlan-infra" = {
        matchConfig.Name = "vlan-infra";
        address = ["10.1.5.1/24"];
        linkConfig.RequiredForOnline = false;
      };
      "45-sfp1.10" = {
        matchConfig.Name = "sfp1.10";
        networkConfig.Bridge = "br-main";
        linkConfig.RequiredForOnline = false;
      };
      "45-sfp1.50" = {
        matchConfig.Name = "sfp1.50";
        networkConfig.Bridge = "br-iot";
        linkConfig.RequiredForOnline = false;
      };
      "45-lan1.10" = {
        matchConfig.Name = "lan1.10";
        networkConfig.Bridge = "br-main";
        linkConfig.RequiredForOnline = false;
      };
      "45-vlan-guest" = {
        matchConfig.Name = "vlan-guest";
        address = ["10.1.20.1/24"];
        linkConfig.RequiredForOnline = false;
      };
      "45-lan1.50" = {
        matchConfig.Name = "lan1.50";
        networkConfig.Bridge = "br-iot";
        linkConfig.RequiredForOnline = false;
      };

      # Bridge L3 interfaces (the per-subnet gateways).
      "50-br-native" = {
        matchConfig.Name = "br-native";
        address = ["10.1.1.1/24"];
        networkConfig.ConfigureWithoutCarrier = true;
        linkConfig.RequiredForOnline = false;
      };
      "50-br-main" = {
        matchConfig.Name = "br-main";
        address = ["10.1.10.1/24"];
        networkConfig.ConfigureWithoutCarrier = true;
        linkConfig.RequiredForOnline = false;
      };
      "50-br-iot" = {
        matchConfig.Name = "br-iot";
        address = ["10.1.50.1/24"];
        networkConfig.ConfigureWithoutCarrier = true;
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  # Don't let a single down LAN port block boot; WAN gates "online".
  systemd.network.wait-online = {
    enable = true;
    anyInterface = false;
    extraArgs = ["--interface=wan0"];
  };
}
