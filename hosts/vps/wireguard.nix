{
  config,
  pkgs,
  ...
}: {
  sops.secrets = {
    "wireguard/allowed_tcp_ports" = {};
    "wireguard/allowed_udp_ports" = {};
    "wireguard/addresses" = {};
    "wireguard/listen_port" = {};
    "wireguard/peers" = {};
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = ["wg0"];
  };

  networking.firewall = {
    allowedTCPPorts = builtins.fromJSON (builtins.readFile config.sops.secrets."wireguard/allowed_tcp_ports".path);
    allowedUDPPorts = builtins.fromJSON (builtins.readFile config.sops.secrets."wireguard/allowed_udp_ports".path);
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
      address = builtins.fromJSON (config.sops.secrets."wireguard/addresses".path);

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

      peers = builtins.fromJSON (builtins.trimString config.sops.secrets."wireguard/peers".path);
    };
  };
}
