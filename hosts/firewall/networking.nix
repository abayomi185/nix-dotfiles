# Networking configuration for the firewall
# Interfaces, bridges, VLANs, IP addressing, NAT
#
# Physical NIC mapping (Proxmox virtio):
#   vtnet0 -> wan0    (WAN uplink, DHCP)
#   vtnet1 -> lan1    (LAN port 1, bridge + VLAN trunk member)
#   vtnet2 -> lan2    (LAN port 2, bridge member)
#   vtnet3 -> lan3    (LAN port 3, bridge member)
#   vtnet4 -> sfp0    (SFP port 1, bridge member)
#   vtnet5 -> sfp1    (SFP port 2, VLAN trunk)
#
# TODO: Update the MAC addresses below after first boot.
#       Find them with: ip link show
{
  config,
  lib,
  pkgs,
  ...
}: let
  # MAC addresses for udev interface renaming
  # Run `ip link show` on the VM and fill these in
  macAddresses = {
    wan0 = "XX:XX:XX:XX:XX:00"; # vtnet0
    lan1 = "XX:XX:XX:XX:XX:01"; # vtnet1
    lan2 = "XX:XX:XX:XX:XX:02"; # vtnet2
    lan3 = "XX:XX:XX:XX:XX:03"; # vtnet3
    sfp0 = "XX:XX:XX:XX:XX:04"; # vtnet4
    sfp1 = "XX:XX:XX:XX:XX:05"; # vtnet5
  };
in {
  # ── Kernel parameters for routing ──────────────────────────────────────
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    # Disable ICMP redirects (security best practice for routers)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Disable bridge netfilter on bridge members
    # (matching OPNsense sysctl net.link.bridge.pfil_member=0)
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;
  };

  # Load bridge netfilter module (needed for the sysctl above)
  boot.kernelModules = ["br_netfilter"];

  # ── Udev rules for descriptive interface names ─────────────────────────
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.wan0}", NAME="wan0"
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.lan1}", NAME="lan1"
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.lan2}", NAME="lan2"
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.lan3}", NAME="lan3"
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.sfp0}", NAME="sfp0"
    SUBSYSTEM=="net", ATTR{address}=="${macAddresses.sfp1}", NAME="sfp1"
  '';

  networking = {
    hostName = "firewall";
    domain = "internal.yomitosh.media";

    # System DNS (for the firewall host itself)
    nameservers = ["127.0.0.1" "1.1.1.1"];

    # Disable DHCP globally; we configure each interface explicitly
    useDHCP = false;

    # ── WAN interface (DHCP from upstream) ─────────────────────────────
    interfaces.wan0 = {
      useDHCP = true;
    };

    # ── Physical LAN interfaces (bridge members, no IP) ───────────────
    # These get their traffic via the bridge they belong to
    interfaces.lan1 = {};
    interfaces.lan2 = {};
    interfaces.lan3 = {};
    interfaces.sfp0 = {};
    interfaces.sfp1 = {};

    # ── VLANs ─────────────────────────────────────────────────────────
    vlans = {
      # VLAN 5 on SFP trunk - Proxmox/Infrastructure
      "sfp1-v5" = {
        id = 5;
        interface = "sfp1";
      };
      # VLAN 10 on SFP trunk - Main LAN
      "sfp1-v10" = {
        id = 10;
        interface = "sfp1";
      };
      # VLAN 50 on SFP trunk - IoT
      "sfp1-v50" = {
        id = 50;
        interface = "sfp1";
      };
      # VLAN 10 on LAN1 (for bridging with sfp1 VLAN 10)
      "lan1-v10" = {
        id = 10;
        interface = "lan1";
      };
      # VLAN 50 on LAN1 (for bridging with sfp1 VLAN 50)
      "lan1-v50" = {
        id = 50;
        interface = "lan1";
      };
    };

    # ── Bridges ───────────────────────────────────────────────────────
    bridges = {
      # Physical LAN bridge - all untagged physical ports
      br-phy = {
        interfaces = ["lan1" "lan2" "lan3" "sfp0" "sfp1"];
      };
      # Main VLAN bridge - VLAN 10 across SFP trunk + LAN1
      br-main = {
        interfaces = ["sfp1-v10" "lan1-v10"];
      };
      # IoT VLAN bridge - VLAN 50 across SFP trunk + LAN1
      br-iot = {
        interfaces = ["sfp1-v50" "lan1-v50"];
      };
    };

    # ── IP addresses on bridges and VLAN interfaces ───────────────────
    interfaces.br-phy = {
      ipv4.addresses = [
        {
          address = "10.1.1.1";
          prefixLength = 24;
        }
      ];
    };

    interfaces.br-main = {
      ipv4.addresses = [
        {
          address = "10.1.10.1";
          prefixLength = 24;
        }
      ];
    };

    interfaces.br-iot = {
      ipv4.addresses = [
        {
          address = "10.1.50.1";
          prefixLength = 24;
        }
      ];
    };

    # VLAN_PHY (tag 5) - standalone, no bridge needed
    interfaces."sfp1-v5" = {
      ipv4.addresses = [
        {
          address = "10.1.5.1";
          prefixLength = 24;
        }
      ];
    };

    # NAT is handled entirely in nftables.nix (table ip nat / masquerade)
  };
}
