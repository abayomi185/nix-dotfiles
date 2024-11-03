{
  inputs,
  config,
  pkgs,
  ...
} @ args: let
  fireflyUser = "firefly-iii";
  fidiUser = "firefly-iii-data-importer";
  fireflyHost = "firefly-internal";
  fireflyDataImporterHost = "firefly-data-importer-internal";
in {
  imports = [
    "${args.inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/firefly-iii-data-importer.nix"
    ./router.nix
  ];

  age.secrets.vps_apps_firefly_iii_app_key = {
    file = "${inputs.nix-secrets}/hosts/vps/apps/firefly-iii/appkey.age";
    owner = fireflyUser;
    group = "nginx";
  };
  age.secrets.vps_apps_firefly_iii_app_url = {
    file = "${inputs.nix-secrets}/hosts/vps/apps/firefly-iii/appurl.age";
    owner = fireflyUser;
    group = "nginx";
  };
  age.secrets.vps_apps_firefly_iii = {
    file = "${inputs.nix-secrets}/hosts/vps/apps/firefly-iii/env.age";
    owner = fireflyUser;
    group = "nginx";
  };
  age.secrets.vps_apps_firefly_iii_data_importer = {
    file = "${inputs.nix-secrets}/hosts/vps/apps/firefly-iii/fidi.env.age";
    owner = fidiUser;
    group = "nginx";
  };

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = fireflyHost;
    settings = {
      # You can leave this on "local". If you change it to production most console commands will ask for extra confirmation. Never set it to "testing".
      APP_ENV = "production";

      # Set to true if you want to see debug information in error screens.
      APP_DEBUG = "false";

      # This should be your email address.
      # If you use Docker or similar, you can set this variable from a file by using SITE_OWNER_FILE
      SITE_OWNER_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";

      # The encryption key for your sessions. Keep this very secure.
      # Change it to a string of exactly 32 chars or use something like `php artisan key:generate` to generate it.
      # If you use Docker or similar, you can set this variable from a file by using APP_KEY_FILE
      APP_KEY_FILE = "${config.age.secrets.vps_apps_firefly_iii_app_key.path}";

      DEFAULT_LANGUAGE = "en_US";

      TZ = "Europe/London";

      TRUSTED_PROXIES = "**";

      # The log channel defines where your log entries go to.
      # Several other options exist. You can use 'single' for one big fat error log (not recommended).
      # Also available are 'syslog', 'errorlog' and 'stdout' which will log to the system itself.
      # A rotating log option is 'daily', creates 5 files that (surprise) rotate.
      # Default setting 'stack' will log to 'daily' and to 'stdout' at the same time.
      LOG_CHANNEL = "stack";

      # Log level. You can set this from least severe to most severe:
      # debug, info, notice, warning, error, critical, alert, emergency
      # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
      # nothing will get logged, ever.
      APP_LOG_LEVEL = "notice";

      # Audit log level.
      # The audit log is used to log notable Firefly III events on a separate channel.
      # These log entries may contain sensitive financial information.
      # The audit log is disabled by default.
      #
      # To enable it, set AUDIT_LOG_LEVEL to "info"
      # To disable it, set AUDIT_LOG_LEVEL to "emergency"
      AUDIT_LOG_LEVEL = "emergency";

      # Database credentials. Make sure the database exists. I recommend a dedicated user for Firefly III
      # For other database types, please see the FAQ: https://docs.firefly-iii.org/references/faq/install/#i-want-to-use-sqlite
      # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
      # Use "pgsql" for PostgreSQL
      # Use "mysql" for MySQL and MariaDB.
      # Use "sqlite" for SQLite.
      DB_CONNECTION = "sqlite";
      # DB_HOST_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";
      # DB_PORT_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";
      # DB_DATABASE_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";
      # DB_USERNAME_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";
      # DB_PASSWORD_FILE = "${config.age.secrets.vps_apps_firefly_iii.path}";
      # leave empty or omit when not using a socket connection
      # DB_SOCKET=

      # Cookie settings. Should not be necessary to change these.
      # If you use Docker or similar, you can set COOKIE_DOMAIN_FILE to set
      # the value from a file instead of from an environment variable
      # Setting samesite to "strict" may give you trouble logging in.
      COOKIE_PATH = "/";
      # COOKIE_DOMAIN=
      # COOKIE_SECURE=false
      # COOKIE_SAMESITE=lax

      # If you want Firefly III to email you, update these settings
      # For instructions, see: https://docs.firefly-iii.org/how-to/firefly-iii/advanced/notifications/#email
      # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
      MAIL_MAILER = "log";
      MAIL_HOST = "null";
      MAIL_PORT = 2525;
      MAIL_FROM = "changeme@example.com";
      MAIL_USERNAME = "null";
      MAIL_PASSWORD = "null";
      MAIL_ENCRYPTION = "null";
      # MAIL_SENDMAIL_COMMAND=

      # Other mail drivers:
      # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
      # MAILGUN_DOMAIN=
      # MAILGUN_SECRET=

      # If you are on EU region in mailgun, use api.eu.mailgun.net, otherwise use api.mailgun.net
      # If you use Docker or similar, you can set this variable from a file by appending it with _FILE
      MAILGUN_ENDPOINT = "api.mailgun.net";

      # Firefly III can send you the following messages.
      SEND_REGISTRATION_MAIL = "true";
      SEND_ERROR_MESSAGE = "true";
      SEND_LOGIN_NEW_IP_WARNING = "true";

      # These messages contain (sensitive) transaction information:
      # SEND_REPORT_JOURNALS = "true";

      # Set this value to true if you want to set the location of certain things, like transactions.
      # Since this involves an external service, it's optional and disabled by default.
      ENABLE_EXTERNAL_MAP = "true";

      # Set this value to true if you want Firefly III to download currency exchange rates
      # from the internet. These rates are hosted by the creator of Firefly III inside
      # an Azure Storage Container.
      # Not all currencies may be available. Rates may be wrong.
      ENABLE_EXTERNAL_RATES = "false";

      # The map will default to this location:
      MAP_DEFAULT_LAT = "${config.age.secrets.vps_apps_firefly_iii.path}";
      MAP_DEFAULT_LONG = "${config.age.secrets.vps_apps_firefly_iii.path}";
      MAP_DEFAULT_ZOOM = "6";

      # Some objects have room for an URL, like transactions and webhooks.
      # By default, the following protocols are allowed:
      # http, https, ftp, ftps, mailto
      #
      # To change this, set your preferred comma separated set below.
      # Be sure to include http, https and other default ones if you need to.
      #
      # VALID_URL_PROTOCOLS=

      # Firefly III supports a few authentication methods:
      # - 'web' (default, uses built in DB)
      # - 'remote_user_guard' for Authelia etc
      # Read more about these settings in the documentation.
      # https://docs.firefly-iii.org/how-to/firefly-iii/advanced/authentication/
      #
      # LDAP is no longer supported :(
      #
      AUTHENTICATION_GUARD = "web";

      # Remote user guard settings #
      AUTHENTICATION_GUARD_HEADER = "REMOTE_USER";
      # AUTHENTICATION_GUARD_EMAIL=

      # Firefly III generates a basic keypair for your OAuth tokens.
      # If you want, you can overrule the key with your own (secure) value.
      # It's also possible to set PASSPORT_PUBLIC_KEY_FILE or PASSPORT_PRIVATE_KEY_FILE
      # if you're using Docker secrets or similar solutions for secret management
      #
      # PASSPORT_PRIVATE_KEY=
      # PASSPORT_PUBLIC_KEY=

      # Firefly III supports webhooks. These are security sensitive and must be enabled manually first.
      #
      ALLOW_WEBHOOKS = "false";

      # The v2 layout is very experimental. If it breaks you get to keep both parts.
      # Be wary of data loss.
      #
      # FIREFLY_III_LAYOUT=v1

      # Please make sure this URL matches the external URL of your Firefly III installation.
      # It is used to validate specific requests and to generate URLs in emails.
      #
      APP_URL_FILE = "${config.age.secrets.vps_apps_firefly_iii_app_url.path}";
    };
  };

  services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = fireflyDataImporterHost;
    settings = {
      # Use cache. No need to do this.
      #
      USE_CACHE = "false";

      # If set to true, the data import will not complain about running into duplicates.
      # This will give you cleaner import mails if you run regular imports.
      #
      # Of course, if something goes wrong *because* the transaction is a duplicate you will
      # NEVER know unless you start digging in your log files. So be careful with this.
      #
      IGNORE_DUPLICATE_ERRORS = "false";

      # Auto import settings. Due to security constraints, you MUST enable each feature individually.
      # You must also set a secret. The secret is used for the web routes.
      #
      # The auto-import secret must be a string of at least 16 characters.
      # Visit this page for inspiration: https://www.random.org/passwords/?num=1&len=16&format=html&rnd=new
      #
      # Submit it using ?secret=X
      #
      # This variable can be set from a file if you append it with _FILE
      #
      # AUTO_IMPORT_SECRET=

      # Import directory white list. You need to set this before the auto importer will accept a directory to import from.
      #
      # This variable can be set from a file if you append it with _FILE
      #
      # IMPORT_DIR_WHITELIST=

      # When you're running Firefly III under a (self-signed) certificate,
      # the data importer may have trouble verifying the TLS connection.
      #
      # You have a few options to make sure the data importer can connect
      # to Firefly III:
      # - 'true': will verify all certificates. The most secure option and the default.
      # - 'file.pem': refer to a file (you must provide it) to your custom root or intermediate certificates.
      # - 'false': will verify NO certificates. Not very secure.
      VERIFY_TLS_SECURITY = "true";

      # If you want, you can set a directory here where the data importer ill look for import configurations.
      # This is a separate setting from the /import directory that the auto-import uses.
      # Setting this variable isn't necessary. The default value is "storage/configurations".
      #
      # This variable can be set from a file if you append it with _FILE
      #
      # JSON_CONFIGURATION_DIR=

      # Time out when connecting with Firefly III.
      # π*10 seconds is usually fine.
      #
      CONNECTION_TIMEOUT = "31.41";

      # The following variables can be useful when debugging the application
      APP_ENV = "production";
      APP_DEBUG = "false";
      LOG_CHANNEL = "stack";

      # Log level. You can set this from least severe to most severe:
      # debug, info, notice, warning, error, critical, alert, emergency
      # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
      # nothing will get logged, ever.
      LOG_LEVEL = "error";

      # TRUSTED_PROXIES is a useful variable when using Docker and/or a reverse proxy.
      # Set it to ** and reverse proxies work just fine.
      TRUSTED_PROXIES = "**";

      # Time zone
      #
      TZ = "Europe/London";

      # Use ASSET_URL when you're running the data importer in a sub-directory.
      #
      # ASSET_URL=

      # Email settings.
      # The data importer can send you a message with all errors, warnings and messages
      # after a successful import. This is disabled by default
      #
      ENABLE_MAIL_REPORT = "false";

      # Force Firefly III URL to be secure?
      #
      #
      EXPECT_SECURE_URL = "false";

      # If enabled, define which mailer you want to use.
      # Options include: smtp, mailgun, postmark, sendmail, log, array
      # Amazon SES is not supported.
      # log = drop mails in the logs instead of sending them
      # array = debug mailer that does nothing.
      # MAIL_MAILER=

      # where to send the report?
      MAIL_DESTINATION_FILE = "${config.age.secrets.vps_apps_firefly_iii_data_importer.path}";

      # other mail settings
      # These variables can be set from a file if you append it with _FILE
      MAIL_FROM_ADDRESS = "noreply@example.com";
      MAIL_HOST = "smtp.mailtrap.io";
      MAIL_PORT = 2525;
      MAIL_USERNAME = "username";
      MAIL_PASSWORD = "password";
      MAIL_ENCRYPTION = "null";

      # Extra settings depending on your mail configuration above.
      # These variables can be set from a file if you append it with _FILE
      # MAILGUN_DOMAIN=
      # MAILGUN_SECRET=
      # MAILGUN_ENDPOINT=
      # POSTMARK_TOKEN=

      # You probably won't need to change these settings.
      #
      BROADCAST_DRIVER = "log";
      CACHE_DRIVER = "file";
      QUEUE_CONNECTION = "sync";
      SESSION_DRIVER = "file";
      SESSION_LIFETIME = 120;
      IS_EXTERNAL = "false";

      APP_NAME = "DataImporter";

      # The APP_URL environment variable is NOT used anywhere.
      # Don't bother setting it to fix your reverse proxy problems. It won't help.
      # Don't open issues telling me it doesn't help because it's not supposed to.
      # Laravel uses this to generate links on the command line, which is a feature the CVS importer does not use.
      #
      APP_URL = "http://localhost";
    };
  };

  services.nginx = {
    virtualHosts."${fireflyHost}" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 9080;
        }
      ];
    };
    virtualHosts."${fireflyDataImporterHost}" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 9081;
        }
      ];
    };
  };
}
