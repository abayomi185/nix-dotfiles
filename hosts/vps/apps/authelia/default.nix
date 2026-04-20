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
    "authelia_oidcHmacSecret" = autheliaSecrets;
    "authelia_oidcJwksPrivateKey" = autheliaSecrets;
  };

  sops.templates."authelia-addon-secrets.yaml" = {
    owner = config.systemd.services.authelia-default.serviceConfig.User;
    content = ''
      session:
        cookies:
          - domain: "${config.sops.placeholder."authelia_domain"}"
            authelia_url: "${config.sops.placeholder."authelia_defaultRedirectionUrl"}"

      identity_providers:
        oidc:
          hmac_secret: "${config.sops.placeholder."authelia_oidcHmacSecret"}"
          jwks:
            - key_id: "default-rs256"
              algorithm: "RS256"
              use: "sig"
              key: |
                ${config.sops.placeholder."authelia_oidcJwksPrivateKey"}
          enable_client_debug_messages: false
          minimum_parameter_entropy: 8
          enforce_pkce: "public_clients_only"
          enable_pkce_plain_challenge: false
          require_pushed_authorization_requests: false
          lifespans:
            access_token: "1h"
            authorize_code: "1m"
            id_token: "1h"
            refresh_token: "90m"

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
      server = {
        endpoints = {
          authz = {
            forward-auth = {
              implementation = "ForwardAuth";
              # Keep the default browser session-based authz flow for now.
            };
          };
        };
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
        remember_me = 864000;
      };
      regulation = {
        max_retries = 3;
        find_time = 120;
        ban_time = 300;
      };
      notifier = {
        smtp = {
          address = "smtp.gmail.com";
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
