{
  config,
  inputs,
  pkgs,
  ...
}: let
  tokenSecret = "hass-cli-token";
  hassCli = pkgs.writeShellApplication {
    name = "hass-cli";
    text = ''
      HASS_TOKEN="$(<"${config.sops.secrets.${tokenSecret}.path}")"
      export HASS_SERVER="http://home.internal.yomitosh.media:8123"
      export HASS_TOKEN

      exec ${pkgs.home-assistant-cli}/bin/hass-cli "$@"
    '';
  };
in {
  sops.secrets.${tokenSecret} = {
    sopsFile = "${inputs.nix-secrets}/shared/hass-cli.enc.yaml";
    key = "token";
  };

  home.packages = [hassCli];
}
