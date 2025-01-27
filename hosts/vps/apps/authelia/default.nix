{
  config,
  inputs,
  ...
}: let
  defaultInstanceDataPath = "/var/lib/authelia-default";
  autheliaSecrets = {
    sopsFile = "${inputs.nix-secrets}/hosts/vps/apps/authelia.enc.yaml";
    owner = config.systemd.services.authelia-default.serviceConfig.User;
  };
in {
  sops.secrets = {
    "authelia_jwtSecret" = autheliaSecrets;
    "authelia_storageEncryptionKey" = autheliaSecrets;
    "authelia_defaultRedirectionUrl" = autheliaSecrets;
    "authelia_domain" = autheliaSecrets;
    "authelia_duoApi_hostname" = autheliaSecrets;
    "authelia_duoApi_integrationKey" = autheliaSecrets;
    "authelia_duoApi_secretKey" = autheliaSecrets;
    "authelia_smtp_username" = autheliaSecrets;
    "authelia_smtp_password" = autheliaSecrets;
  };

  sops.templates."authelia-addon-secrets.yaml" = {
    owner = config.systemd.services.authelia-default.serviceConfig.User;
    content = ''
      session:
        domain: "${config.sops.placeholder."authelia_domain"}"

      default_redirection_url: "${config.sops.placeholder."authelia_defaultRedirectionUrl"}"

      notifier:
        smtp:
          username: "${config.sops.placeholder."authelia_smtp_username"}"
          password: "${config.sops.placeholder."authelia_smtp_password"}"
          sender: "authelia@${config.sops.placeholder."authelia_domain"}"

      access_control:
        rules:
          - domain: "*.${config.sops.placeholder."authelia_domain"}"
            policy: two_factor
    '';
  };

  services.authelia.instances.default = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia_jwtSecret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia_storageEncryptionKey".path;
    };
    settingsFiles = [
      "${config.sops.templates."authelia-addon-secrets.yaml".path}"
    ];
    settings = {
      log.level = "info"; # debug, trace
      authentication_backend = {
        file.path = "${defaultInstanceDataPath}/users_database.yml";
      };
      totp.issuer = "authelia.com";
      duo_api = {
        enable_self_enrollment = true;
      };
      access_control = {
        default_policy = "deny";
      };
      session = {
        expiration = 5400;
        inactivity = 1800;
        remember_me_duration = 864000;
      };
      regulation = {
        max_retries = 3;
        find_time = 120;
        ban_time = 300;
      };
      notifier = {
        smtp = {
          host = "smtp.gmail.com";
          port = 587;
        };
      };
      storage = {
        local = {
          path = "${defaultInstanceDataPath}/db.sqlite3";
        };
      };
    };
  };
}
