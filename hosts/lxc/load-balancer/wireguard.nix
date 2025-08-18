{
  config,
  inputs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsJson = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/lxc/load-balancer/secrets.toml");

  secret_address = secretsJson.interface.address;
  secret_peers = secretsJson.wireguard.peers;

  wireguardSecrets.sopsFile = "${inputs.nix-secrets}/hosts/lxc/load-balancer/wireguard.enc.yaml";
in {
  sops.secrets = {
    "privateKey" = wireguardSecrets;
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = secret_address;

      privateKeyFile = config.sops.secrets."privateKey".path;

      peers = secret_peers;
    };
  };
}
