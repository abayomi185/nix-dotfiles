# UniFi hardware, managed through the controller API on the firewall.
# Rendered to Terraform JSON by terranix; run with `nix run .#unifi -- plan`.
{lib, ...}: let
  ref = name: "\${${name}}";
  networkId = name:
    if name == "default"
    then ref "data.unifi_network.default.id"
    else ref "unifi_network.${name}.id";

  switchMac = "d0:21:f9:4b:f6:ea"; # YHLD-SWCH2

  # Third-party-gateway VLANs; the firewall routes and serves DHCP.
  networks = {
    infra = {
      name = "Infra";
      vlan = 5;
    };
    main = {
      name = "Main";
      vlan = 10;
    };
    guest = {
      name = "Guest";
      vlan = 20;
    };
    iot = {
      name = "IoT";
      vlan = 50;
    };
  };

  # Managed YHLD-SWCH2 ports, named after what's plugged in (or the VLAN for
  # spare access ports); undeclared ports keep their controller config.
  switchPorts = {
    "1" = {
      name = "Foreign AP";
      native = "iot";
    };
    "2" = {
      name = "Infra access";
      native = "infra";
    };
    "3" = {
      name = "Guest access";
      native = "guest";
    };
    "13" = {
      name = "YHLD-IPMI1";
      native = "infra";
    };
    "15" = {
      name = "YHLD-SLZB1";
      native = "iot";
    };
    "21" = {
      name = "YHLD-ACPT2";
      native = "default";
      forward = "all";
    };
    "23" = {
      name = "YHLD-GMBX1";
      native = "main";
    };
    "24" = {
      name = "Main access";
      native = "main";
    };
    "26" = {
      name = "YHLD-SERV1";
      native = "infra";
      poe = false;
      autoneg = false;
      speed = 10000;
      full_duplex = true;
    };
  };

  # Declared on unifi_device so all ports go out in one write; separate
  # unifi_device_port resources race and overwrite each other.
  portOverride = index: p:
    {
      index = lib.toInt index;
      inherit (p) name;
      native_networkconf_id = networkId p.native;
      forward = p.forward or "customize";
      autoneg = p.autoneg or true;
      # Controller defaults; not computed by the provider, so pin them.
      setting_preference = "auto";
      stp_edge_state = "auto";
      tagged_vlan_mgmt = "auto";
    }
    // lib.optionalAttrs (p.poe or true) {poe_mode = "auto";}
    // lib.filterAttrs (n: _: lib.elem n ["speed" "full_duplex"]) p;
in {
  terraform = {
    required_providers.unifi.source = "ubiquiti-community/unifi";

    # State is committed to git, encrypted with a passphrase from sops.
    encryption = {
      key_provider.pbkdf2.state.passphrase = ref "var.state_passphrase";
      method.aes_gcm.state.keys = "key_provider.pbkdf2.state";
      state = {
        method = "method.aes_gcm.state";
        enforced = true;
      };
      plan = {
        method = "method.aes_gcm.state";
        enforced = true;
      };
    };
  };

  variable.state_passphrase = {
    type = "string";
    sensitive = true;
  };

  # api_key comes from UNIFI_API_KEY.
  provider.unifi = {
    api_url = "https://firewall.internal.yomitosh.media:11443";
    site = "default";
    allow_insecure = true;
  };

  data.unifi_network.default.name = "Default";

  resource = {
    unifi_network =
      lib.mapAttrs (_: n: {
        inherit (n) name vlan;
        third_party_gateway = true;
      })
      networks;

    unifi_device = {
      switch = {
        mac = switchMac;
        name = "yhld-swch2";
        stp.version = "rstp";
        led.override = "on";
        port_override = lib.mapAttrsToList portOverride switchPorts;
      };

      ap = {
        mac = "d0:21:f9:b1:8e:74";
        name = "yhld-acpt2";
        led.override = "on";
      };
    };
  };

  # NOTE: one-off; forget the old per-port resources without touching ports.
  removed = map (i: {
    from = "unifi_device_port.switch_${i}";
    lifecycle.destroy = false;
  }) ["1" "2" "3" "7" "11" "13" "26"];
}
