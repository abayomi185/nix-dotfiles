# VPS WireGuard hub — reuses the legacy vps-arm64 tunnel identity so every
# existing peer keeps the same server key during the cutover.
#
# Peers come from the shared registry (nix-secrets shared/wireguard.nix).
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  wg = import ../shared/wireguard.nix {inherit inputs;};
in {
  sops.secrets."wireguard/privateKey" = {};

  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

  networking.nameservers = ["10.13.13.2" "8.8.8.8"];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "ens18";
    internalInterfaces = ["wg0"];
  };

  # Only the WireGuard listener is public; DNS stays on wg0. Kubelet and
  # flannel VXLAN (unauthenticated) accept the knodes only, not every peer.
  networking.firewall.allowedUDPPorts = [wg.hub.listenPort];
  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -i wg0 -m iprange --src-range 10.1.5.71-10.1.5.74 -p tcp --dport 10250 -j nixos-fw-accept
    iptables -A nixos-fw -i wg0 -m iprange --src-range 10.1.5.71-10.1.5.74 -p udp --dport 8472 -j nixos-fw-accept
  '';

  # VPN clients use this as DNS: internal zones go to the firewall's Unbound.
  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      interface = "wg0";
      server = [
        "/internal.yomitosh.media/10.13.13.2"
        "/local.yomitosh.media/10.13.13.2"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  # dnsmasq binds to wg0; at boot it otherwise races wg-quick, fails with
  # "unknown interface wg0" and hits the restart limit, leaving VPN DNS down.
  systemd.services.dnsmasq = {
    after = ["wg-quick-wg0.service"];
    wants = ["wg-quick-wg0.service"];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = ["${wg.hub.address}/24"];
    privateKeyFile = config.sops.secrets."wireguard/privateKey".path;
    inherit (wg.hub) listenPort;

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
    '';

    peers =
      lib.mapAttrsToList (_: peer: {
        inherit (peer) publicKey;
        allowedIPs = ["${peer.address}/32"] ++ peer.allowedIPs or [];
      })
      wg.peers;
  };

  # Home LANs behind the firewall peer.
  networking.interfaces.wg0.ipv4.routes = map (address: {
    inherit address;
    prefixLength = 24;
    via = wg.peers.firewall.address;
  }) ["10.1.10.0" "10.1.50.0" "10.1.1.0"];
}
