# VPS WireGuard hub — reuses the legacy vps-arm64 tunnel identity so every
# existing peer keeps the same server key during the cutover.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  vpnHubSecrets = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");
  vpnNameservers = ["10.13.13.2"] ++ vpnHubSecrets.network.nameservers;
  vpnDnsForwarders = vpnHubSecrets.dnsmasq.server;
in {
  sops.secrets."wireguard/privateKey" = {};

  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

  networking.nameservers = lib.unique vpnNameservers;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "ens18";
    internalInterfaces = ["wg0"];
  };

  networking.firewall.allowedTCPPorts = lib.unique (vpnHubSecrets.wireguard.allowed_tcp_ports ++ [10250]);
  networking.firewall.allowedUDPPorts = lib.unique (vpnHubSecrets.wireguard.allowed_udp_ports ++ [8472]);

  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      interface = "wg0";
      server = vpnDnsForwarders;
    };
  };

  networking.wg-quick.interfaces.wg0 = {
    address = vpnHubSecrets.wireguard.addresses;
    privateKeyFile = config.sops.secrets."wireguard/privateKey".path;
    listenPort = vpnHubSecrets.wireguard.listen_port;

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

    peers = vpnHubSecrets.wireguard.peers;
  };

  networking.interfaces.wg0.ipv4.routes =
    lib.map
    (route: {
      address = route.address;
      prefixLength = route.prefix_length;
      via = route.via;
    })
    vpnHubSecrets.wireguard.routes;
}
