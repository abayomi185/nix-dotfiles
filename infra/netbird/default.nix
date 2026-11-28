# NetBird groups, policies, networks and setup keys, managed through the
# management API on YHLD-VPSR1. Peers enrol themselves (SSO or setup key).
# Rendered to Terraform JSON by terranix; run with `nix run .#netbird -- plan`.
{lib, ...}: let
  ref = name: "\${${name}}";

  # Home LANs reachable through netbird-router; same set as the WireGuard hub.
  homeLans = {
    infra = "10.1.5.0/24";
    main = "10.1.10.0/24";
    iot = "10.1.50.0/24";
  };
in {
  terraform = {
    required_providers.netbird.source = "netbirdio/netbird";

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

  # token comes from NB_PAT (a personal access token made in the dashboard).
  provider.netbird.management_url = "https://netbird.yomitosh.media";

  data.netbird_group.all.name = "All";

  resource = {
    netbird_group = {
      routers.name = "routers";
      home-lans.name = "home-lans";
    };

    netbird_setup_key.router = {
      name = "netbird-router";
      type = "reusable";
      auto_groups = [(ref "netbird_group.routers.id")];
    };

    netbird_network.home = {
      name = "home";
      description = "Home LANs via netbird-router";
    };

    netbird_network_resource =
      lib.mapAttrs (name: address: {
        inherit name address;
        network_id = ref "netbird_network.home.id";
        groups = [(ref "netbird_group.home-lans.id")];
      })
      homeLans;

    netbird_network_router.home = {
      network_id = ref "netbird_network.home.id";
      peer_groups = [(ref "netbird_group.routers.id")];
      masquerade = true;
    };

    netbird_policy.home-lans = {
      name = "home-lans";
      description = "Every peer can reach the home LANs";
      rule = {
        name = "all-to-home-lans";
        action = "accept";
        protocol = "all";
        bidirectional = false;
        sources = [(ref "data.netbird_group.all.id")];
        destinations = [(ref "netbird_group.home-lans.id")];
      };
    };
  };

  output.router_setup_key = {
    value = ref "netbird_setup_key.router.key";
    sensitive = true;
  };
}
