# WireGuard client for the YHLD-VPSR1 hub, delivered as a configuration
# profile for WireGuard.app so the app's toggle and On-Demand UI keep working.
#
# sops-nix renders the profile with this Mac's private key at activation.
# Install or update it with:
#   open ~/.config/sops-nix/secrets/rendered/wireguard.mobileconfig
# then approve it in System Settings → General → Device Management.
# The fixed PayloadIdentifier makes a reinstall replace the previous tunnels.
#
# Tunnels:
#   home  split: tunnel subnet + home LANs, toggled manually
#   vps   full: On-Demand on any Wi-Fi except trustedSSIDs, off on Ethernet
{pPeer}: {
  config,
  inputs,
  lib,
  ...
}: let
  wg = import "${builtins.toString inputs.nix-secrets}/shared/wireguard.nix";
  peer = wg.peers.${pPeer};
  trustedSSIDs = ["Airport"];

  # Swapped for the sops placeholder after plist escaping (which would mangle it).
  privateKey = "@WIREGUARD_PRIVATE_KEY@";

  # DNS is dnsmasq on the hub; it forwards internal zones to the firewall.
  wgQuickConfig = allowedIPs: ''
    [Interface]
    PrivateKey = ${privateKey}
    Address = ${peer.address}/32
    DNS = ${wg.hub.address}

    [Peer]
    PublicKey = ${wg.hub.publicKey}
    AllowedIPs = ${lib.concatStringsSep ", " allowedIPs}
    Endpoint = ${wg.hub.endpoint}
    PersistentKeepalive = 25
  '';

  # Stable UUIDs so a reinstall updates rather than duplicates.
  uuid = name: let
    h = builtins.hashString "sha256" "wireguard-${pPeer}-${name}";
    s = start: len: lib.substring start len h;
  in
    lib.toUpper "${s 0 8}-${s 8 4}-${s 12 4}-${s 16 4}-${s 20 12}";

  tunnel = {
    name,
    allowedIPs,
    onDemand ? {},
  }: {
    PayloadDisplayName = "VPN";
    PayloadType = "com.apple.vpn.managed";
    PayloadVersion = 1;
    PayloadIdentifier = "media.yomitosh.wireguard.${name}";
    PayloadUUID = uuid name;
    UserDefinedName = name;
    VPNType = "VPN";
    VPNSubType = "com.wireguard.macos";
    VendorConfig.WgQuickConfig = wgQuickConfig allowedIPs;
    VPN =
      {
        RemoteAddress = wg.hub.endpoint;
        AuthenticationMethod = "Password";
      }
      // onDemand;
  };

  # Rule shape matches the app's "Wi-Fi only, except these SSIDs" option so
  # it stays editable in WireGuard.app.
  untrustedWiFi = {
    OnDemandEnabled = 1;
    OnDemandRules = [
      {
        Action = "Disconnect";
        InterfaceTypeMatch = "WiFi";
        SSIDMatch = trustedSSIDs;
      }
      {
        Action = "Connect";
        InterfaceTypeMatch = "WiFi";
      }
      {
        Action = "Disconnect";
        InterfaceTypeMatch = "Ethernet";
      }
    ];
  };

  profile = lib.generators.toPlist {escape = true;} {
    PayloadDisplayName = "WireGuard (${pPeer})";
    PayloadType = "Configuration";
    PayloadVersion = 1;
    PayloadIdentifier = "media.yomitosh.wireguard";
    PayloadUUID = uuid "profile";
    PayloadContent = [
      (tunnel {
        name = "home";
        allowedIPs = ["10.13.13.0/24"] ++ wg.peers.firewall.allowedIPs;
      })
      (tunnel {
        name = "vps";
        allowedIPs = ["0.0.0.0/0" "::/0"];
        onDemand = untrustedWiFi;
      })
    ];
  };
in {
  sops.secrets."wireguard/privateKey" = {};
  sops.templates."wireguard.mobileconfig".content =
    builtins.replaceStrings [privateKey] [config.sops.placeholder."wireguard/privateKey"] profile;
}
