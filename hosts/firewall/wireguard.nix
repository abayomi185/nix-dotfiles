# WireGuard VPN tunnel to VPS
# Migrated from OPNsense WireGuard configuration
#
# SETUP: Before this works, you must create the sops secret file:
#   1. In your nix-secrets repo, create hosts/firewall/wireguard.enc.yaml
#   2. Add the key: wireguard/privateKey
#   3. Encrypt it with sops
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  hasSecretFile = builtins.pathExists "${secretsPath}/hosts/firewall/wireguard.enc.yaml";
in {
  # ── Secrets ─────────────────────────────────────────────────────────────
  sops.secrets."wireguard/privateKey" = lib.mkIf hasSecretFile {
    sopsFile = "${secretsPath}/hosts/firewall/wireguard.enc.yaml";
  };

  # ── WireGuard interface ─────────────────────────────────────────────────
  networking.wg-quick.interfaces.wg0 = {
    # Local address on the WireGuard tunnel
    address = ["10.13.13.2/32"];

    # Private key from sops (falls back to a file path for manual setup)
    privateKeyFile = config.sops.secrets."wireguard/privateKey".path

    # MSS clamping is handled in nftables.nix

    peers = [
      {
        # VPS peer
        publicKey = "{public key}";
        allowedIPs = ["10.13.13.0/24"];
        endpoint = "wireguard.yomitosh.media:42773";
        persistentKeepalive = 25;
      }
    ];
  };

  # ── Route to WireGuard network via the VPS gateway ──────────────────────
  networking.interfaces.wg0.ipv4.routes = [
    {
      address = "10.13.13.0";
      prefixLength = 24;
      via = "10.13.13.1";
    }
  ];
}
