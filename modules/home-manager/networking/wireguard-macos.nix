# macOS WireGuard client for the YHLD-VPSR1 hub, delivered as a configuration
# profile for WireGuard.app; tunnels are toggled in the app.
#
# sops-nix renders the profile with this Mac's private key at activation.
# When its contents change, a launchd agent opens it; approve it in
# System Settings → General → Device Management. (macOS only installs
# profiles silently via MDM.) To reinstall by hand:
#   open ~/.config/sops-nix/secrets/rendered/wireguard.mobileconfig
# The fixed PayloadIdentifier makes a reinstall replace the previous tunnels.
#
# Tunnels:
#   home  split: tunnel subnet + home LANs
#   vps   full tunnel
{pPeer}: {
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  wg = import "${builtins.toString inputs.nix-secrets}/shared/wireguard.nix";
  peer = wg.peers.${pPeer};

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
    VPN = {
      RemoteAddress = wg.hub.endpoint;
      AuthenticationMethod = "Password";
    };
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
      })
    ];
  };

  renderedProfile = config.sops.templates."wireguard.mobileconfig".path;

  # sops-nix re-renders on every login and activation, so only open the
  # profile when its hash differs from the last one opened.
  openIfChanged = pkgs.writeShellScript "wireguard-profile-open" ''
    state="${config.xdg.stateHome}/wireguard/profile.sha256"
    [ -f "${renderedProfile}" ] || exit 0
    new=$(/usr/bin/shasum -a 256 "${renderedProfile}" | /usr/bin/cut -d' ' -f1)
    [ "$new" = "$(cat "$state" 2>/dev/null)" ] && exit 0
    mkdir -p "$(dirname "$state")"
    /usr/bin/open "${renderedProfile}" && echo "$new" > "$state"
  '';
in {
  sops.secrets."wireguard/privateKey" = {};
  sops.templates."wireguard.mobileconfig".content =
    builtins.replaceStrings [privateKey] [config.sops.placeholder."wireguard/privateKey"] profile;

  # sops-nix swaps its secrets symlink inside this directory after rendering,
  # which triggers the agent. RunAtLoad covers a render that finished before
  # the agent loaded (login, first deploy).
  launchd.agents.wireguard-profile = {
    enable = true;
    config = {
      ProgramArguments = ["${openIfChanged}"];
      RunAtLoad = true;
      WatchPaths = [(builtins.dirOf config.sops.defaultSymlinkPath)];
    };
  };
}
