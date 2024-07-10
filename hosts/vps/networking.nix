{
  config,
  lib,
  ...
}: {
  sops.secrets = {
    "network/nameservers/a" = {};
    "network/default_gateway" = {};
    "network/ipv4_address" = {};
    "network/ipv6_address" = {};
    "network/mac_address" = {};
    "network/enp7s0_mac_address" = {};
    "network/enp7s0_ipv4_address" = {};
  };

  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      config.sops.secrets."network/nameservers/a".path
    ];
    defaultGateway = config.sops.secrets."network/default_gateway".path;
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
            address = config.sops.secrets."network/ipv4_address".path;
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = config.sops.secrets."network/ipv6_address".path;
            prefixLength = 64;
          }
          {
            address = "fe80::9400:3ff:fe5c:7467";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = config.sops.secrets."network/default_gateway".path;
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
            address = config.sops.secrets."network/enp7s0_ipv4_address".path;
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
    ATTR{address}=="${config.sops.secrets."network/mac_address".path}", NAME="eth0"
    ATTR{address}=="${config.sops.secrets."network/enp7s0_mac_address".path}", NAME="enp7s0"
  '';
}
