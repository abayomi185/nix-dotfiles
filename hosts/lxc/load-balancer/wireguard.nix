{
  config,
  inputs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsAttributeSet = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/lxc/load-balancer/secrets.toml");

  secret_address = secretsAttributeSet.wireguard.interface.address;
  secret_peers = secretsAttributeSet.wireguard.peers;

  wireguardSopsFile = "${inputs.nix-secrets}/hosts/lxc/load-balancer/wireguard.enc.yaml";
in {
  sops.secrets.wireguardPrivateKey = {
    format = "yaml";
    sopsFile = wireguardSopsFile;
    key = "privateKey";
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = secret_address;

      privateKeyFile = config.sops.secrets.wireguardPrivateKey.path;

      peers = secret_peers;
    };
  };
}
