# WireGuard — outbound client tunnel to the VPS.
#
# The firewall dials the VPS (it does not listen): reusing the OPNsense WG0
# keypair means the VPS peer config is unchanged at cutover.
#
#   firewall  10.13.13.2  <-- wg -->  10.13.13.1  VPS (wireguard.yomitosh.media)
#
# The private key lives in nix-secrets at hosts/firewall/default.enc.yaml
# (key wireguard/privateKey), encrypted to the dedicated &firewall age key.
{config, ...}: {
  sops.secrets."wireguard/privateKey" = {};

  networking.wg-quick.interfaces.wg0 = {
    address = ["10.13.13.2/32"];
    privateKeyFile = config.sops.secrets."wireguard/privateKey".path;

    # MSS clamping for the tunnel lives in nftables.nix.
    peers = [
      {
        # VPS WireGuard server.
        publicKey = "5zyIMCJ0eeTmXP/QrqnM7JmkZPN77PpU2u+dMazyzi4=";
        allowedIPs = ["10.13.13.0/24"];
        endpoint = "wireguard.yomitosh.media:42773";
        persistentKeepalive = 25;
      }
    ];
  };
}
