{
  inputs,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsJson = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");

  secret_allowedTcpPorts = secretsJson.wireguard.allowed_tcp_ports;
  secret_allowedUdpPorts = secretsJson.wireguard.allowed_udp_ports;
  secret_addresses = secretsJson.wireguard.addresses;
  secret_peers = secretsJson.wireguard.peers;
in {
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = ["wg0"];
  };

  networking.firewall = {
    allowedTCPPorts = secret_allowedTcpPorts;
    allowedUDPPorts = secret_allowedUdpPorts;
  };

  services = {
    dnsmasq = {
      enable = true;
      settings = {
        interface = "wg0";
      };
    };
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = secret_addresses;

      privateKeyFile = "~/nix-dotfiles/hosts/vps/.wireguard-privatekey";

      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
      '';

      peers = secret_peers;
    };
  };
}
