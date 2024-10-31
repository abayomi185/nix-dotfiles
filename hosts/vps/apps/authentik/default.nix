{
  config,
  inputs,
  ...
}: {
  sops.secrets = {
    "authentik.env".sopsFile = "${inputs.nix-secrets}/hosts/vps/apps/authentik.enc.yaml";
  };

  services.authentik = {
    enable = false; # Using Authelia instead
    environmentFile = config.sops.secrets."authentik.env".path;
    settings = {
      email = {
        # email settings
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
}
