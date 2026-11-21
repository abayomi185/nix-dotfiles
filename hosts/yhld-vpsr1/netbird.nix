# NetBird control plane (management, signal, relay, dashboard), trialled
# alongside the WireGuard hub.
#
# k3s Traefik owns :80/:443, so these services listen on host ports and the
# `public` entrypoint routes netbird.yomitosh.media to them (home-ops
# apps/base/network-system/netbird). Only STUN (UDP 3478) is public here.
# netbird.yomitosh.media must be a DNS-only (grey) Cloudflare record: STUN is
# UDP and gRPC streams don't survive the proxy.
#
# Login is SSO through Authelia (OIDC client `netbird`). Groups, policies,
# networks and setup keys live in infra/netbird.
#
# Server modules and packages come from unstable: 26.05 ships 0.71 without
# the relay module.
{
  config,
  inputs,
  pkgs,
  ...
}: let
  domain = "netbird.yomitosh.media";
  authelia = "https://auth.yomitosh.media";
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  unstableModules = "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/netbird";

  ports = {
    management = 8011;
    signal = 8012;
    relay = 33080;
    dashboard = 8013;
  };
in {
  disabledModules = ["services/networking/netbird/server.nix"];
  imports = [
    "${unstableModules}/server.nix"
    "${unstableModules}/netbird-relay.nix"
  ];

  sops.secrets."netbird/dataStoreEncryptionKey" = {};
  sops.secrets."netbird/relayAuthSecret" = {};

  services.netbird.server = {
    enable = true;
    inherit domain;

    dashboard = {
      package = unstable.netbird-dashboard;
      enableNginx = true;
      settings = {
        AUTH_AUTHORITY = authelia;
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        AUTH_REDIRECT_URI = "/nb-auth";
        AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
      };
    };

    signal = {
      package = unstable.netbird-signal;
      port = ports.signal;
    };

    management = {
      package = unstable.netbird-management;
      port = ports.management;
      oidcConfigEndpoint = "${authelia}/.well-known/openid-configuration";
      settings = {
        DataStoreEncryptionKey._secret = config.sops.secrets."netbird/dataStoreEncryptionKey".path;

        Stuns = [
          {
            Proto = "udp";
            URI = "stun:${domain}:3478";
            Username = "";
            Password = null;
          }
        ];
        # No coturn: the relay covers peers that can't connect directly.
        TURNConfig = {
          Turns = [];
          Secret._secret = config.sops.secrets."netbird/relayAuthSecret".path;
        };
        Relay = {
          Addresses = ["rels://${domain}:443/relay"];
          CredentialsTTL = "24h";
          Secret._secret = config.sops.secrets."netbird/relayAuthSecret".path;
        };

        # Clients send Authelia ID tokens (aud = client id).
        HttpConfig = {
          AuthIssuer = authelia;
          AuthAudience = "netbird";
          AuthKeysLocation = "${authelia}/jwks.json";
        };
        PKCEAuthorizationFlow.ProviderConfig = {
          AuthorizationEndpoint = "${authelia}/api/oidc/authorization";
          TokenEndpoint = "${authelia}/api/oidc/token";
          Scope = "openid profile email groups";
          RedirectURLs = ["http://localhost:53000/" "http://localhost:54000/"];
          UseIDToken = true;
        };
      };
    };
  };

  # Traefik only needs the dashboard from nginx; it routes API, gRPC and relay
  # traffic straight to the services.
  services.nginx.virtualHosts.${domain}.listen = [
    {
      addr = "0.0.0.0";
      port = ports.dashboard;
    }
  ];

  services.netbird.relay = {
    enable = true;
    package = unstable.netbird-relay;
    authSecretFile = config.sops.secrets."netbird/relayAuthSecret".path;
    openFirewall = true; # STUN
    settings = {
      listen-address = ":${toString ports.relay}";
      exposed-address = "rels://${domain}:443/relay";
      enable-stun = true;
    };
  };

  # Traefik pods reach the host over the flannel bridge.
  networking.firewall.interfaces.cni0.allowedTCPPorts = builtins.attrValues ports;
}
