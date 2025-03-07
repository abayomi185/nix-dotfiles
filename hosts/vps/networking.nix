{
  config,
  inputs,
  lib,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsJson = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");

  secret_nameservers = secretsJson.network.nameservers;
  secret_defaultGateway = secretsJson.network.default_gateway;
  secret_macAddress = secretsJson.network.mac_address;
  secret_ipv4Address = secretsJson.network.ipv4_address;
  secret_ipv6Address = secretsJson.network.ipv6_address;
  secret_enp7s0MacAddress = secretsJson.network.enp7s0_mac_address;
  secret_enp7s0Ipv4Address = secretsJson.network.enp7s0_ipv4_address;

  secret__dnsmasq_address = secretsJson.dnsmasq.address;
  secret__dnsmasq_server = secretsJson.dnsmasq.server;
in {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = secret_nameservers;
    defaultGateway = secret_defaultGateway;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = secret_ipv4Address;
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = secret_ipv6Address;
            prefixLength = 64;
          }
          {
            address = "fe80::9400:3ff:fe5c:7467";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = secret_defaultGateway;
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "fe80::1";
            prefixLength = 128;
          }
        ];
      };
      enp7s0 = {
        ipv4.addresses = [
          {
            address = secret_enp7s0Ipv4Address;
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::8400:ff:fe8d:e4d1";
            prefixLength = 64;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="${secret_macAddress}", NAME="eth0"
    ATTR{address}=="${secret_enp7s0MacAddress}", NAME="enp7s0"
  '';

  # DNS
  services.dnsmasq = {
    enable = true;
    settings = {
      address = secret__dnsmasq_address;
      server = secret__dnsmasq_server;
    };
  };
}
