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
      name = "IOT";
      vlan = 50;
    };
  };

  # Managed YHLD-SWCH2 ports; undeclared ports keep their controller config.
  switchPorts = {
    "1" = {
      native = "default";
      forward = "all";
    }; # YHLD-ACPT2
    "2" = {native = "infra";};
    "3" = {
      name = "guest-net1";
      native = "guest";
    };
    "7" = {
      name = "zigbee-matter-coordinator";
      native = "iot";
    }; # YHLD-SLZB1
    "11" = {
      name = "pve-ipmi";
      native = "infra";
    }; # YHLD-IPMI1
    "13" = {native = "main";};
    "26" = {
      name = "pve-main";
      native = "infra";
      poe = false;
      autoneg = false;
      speed = 10000;
      full_duplex = true;
    }; # YHLD-SERV1
  };

  switchPort = index: p:
    {
      device_mac = switchMac;
      index = lib.toInt index;
      name = p.name or "Port ${index}";
      native_networkconf_id = networkId p.native;
      forward = p.forward or "customize";
      # Controller defaults; not computed by the provider, so pin them.
      setting_preference = "auto";
      stp_edge_state = "auto";
      tagged_vlan_mgmt = "auto";
    }
    // lib.optionalAttrs (p.poe or true) {poe_mode = "auto";}
    // lib.filterAttrs (n: _: lib.elem n ["autoneg" "speed" "full_duplex"]) p;
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
      };

      ap = {
        mac = "d0:21:f9:b1:8e:74";
        name = "yhld-acpt2";
        led.override = "on";
      };
    };

    unifi_device_port = lib.mapAttrs' (i: p: lib.nameValuePair "switch_${i}" (switchPort i p)) switchPorts;
  };

  # NOTE: one-off adoption of existing controller objects; drop after first apply.
  import =
    lib.mapAttrsToList (n: id: {
      to = "unifi_network.${n}";
      inherit id;
    }) {
      infra = "6a6940379c1aaf63a60e8e36";
      main = "6a693fd09c1aaf63a60e8e29";
      guest = "6a6940269c1aaf63a60e8e33";
      iot = "6a693ff09c1aaf63a60e8e30";
    }
    ++ [
      {
        to = "unifi_device.switch";
        id = "6a6a8ebe0d852a4ee3101fe5";
      }
      {
        to = "unifi_device.ap";
        id = "6a6a8f160d852a4ee3101fe7";
      }
    ]
    ++ lib.mapAttrsToList (i: _: {
      to = "unifi_device_port.switch_${i}";
      id = "${switchMac}/${i}";
    })
    switchPorts;
}
