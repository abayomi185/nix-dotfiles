{
  config,
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
  secret_listenPort = secretsJson.wireguard.listen_port;

  secret_wireguardRoute_address = secretsJson.wireguard.route.address;
  secret_wireguardRoute_via = secretsJson.wireguard.route.via;

  wireguardSecrets.sopsFile = "${inputs.nix-secrets}/hosts/vps/wireguard.enc.yaml";
in {
  sops.secrets = {
    "privateKey" = wireguardSecrets;
  };

  age.secrets.vps_wireguard.file = "${inputs.nix-secrets}/hosts/vps/wireguard.age";

  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

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

      privateKeyFile = config.sops.secrets."privateKey".path;

      listenPort = secret_listenPort;

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

  networking.interfaces.wg0.ipv4.routes = [
    {
      address = secret_wireguardRoute_address;
      prefixLength = 24;
      via = secret_wireguardRoute_via;
    }
  ];
}
