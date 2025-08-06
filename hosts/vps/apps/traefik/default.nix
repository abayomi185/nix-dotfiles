{...}: let
  basePath = "/home/cloud/nix-dotfiles/hosts/vps/apps/traefik";
  dataPath = "/var/lib/traefik";
in {
  networking.firewall.allowedTCPPorts = [80 443];

  imports = [
    # Middlewares
    ./middleware/https_redirect.nix
    ./middleware/landing_page.nix
    ./middleware/rate_limit.nix
    ./middleware/authelia.nix

    # File Providers
    ./file-provider/auth.nix
    ./file-provider/chat.nix
    ./file-provider/comfyui.nix
    ./file-provider/jellyfin.nix
    ./file-provider/nextcloud.nix
    ./file-provider/openchat.nix
    # ./file-provider/home.nix
    ./file-provider/yomitosh.nix
  ];

  services.traefik = {
    enable = true;
    environmentFiles = [
      "${basePath}/.env"
    ];

    # Traefik Static Config
    staticConfigOptions = {
      ################################################################
      # Global configuration
      ################################################################
      global = {
        checkNewVersion = true;
        sendAnonymousUsage = false;
      };

      ################################################################
      # EntryPoints configuration
      ################################################################
      entryPoints = {
        web = {
          address = ":80";
          http = {
            middlewares = ["global_rate_limit@file"];
            # forwardedHeaders = {
            #   trustedIPs = [ "10.13.13.1/24" ];
            # };
            # };
            redirections = {
              entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
          };
        };
        websecure = {
          address = ":443";
          http = {
            middlewares = ["global_rate_limit@file"];
            # forwardedHeaders = {
            # trustedIPs = ["10.13.13.1/24"];
            # };
            tls = {
              domains = [
                {
                  main = ''{{ env "MEDIA_DOMAIN_NAME" }}'';
                  sans = [''*.{{env "MEDIA_DOMAIN_NAME"}}''];
                }
                {
                  main = ''{{env "BLOG_DOMAIN_NAME"}}'';
                  sans = [''*.{{env "BLOG_DOMAIN_NAME"}}''];
                }
                {
                  main = ''{{env "INTERNAL_DOMAIN_NAME"}}'';
                  sans = [''*.{{env "INTERNAL_DOMAIN_NAME"}}''];
                }
              ];
            };
          };
        };
      };

      serversTransport = {
        insecureSkipVerify = true;
      };

      ################################################################
      # Traefik logs configuration
      ################################################################
      log = {
        # Log level
        #
        # Optional
        # Default: "ERROR"
        #
        # level = "DEBUG";
        level = "ERROR";

        # Sets the filepath for the traefik log. If not specified, stdout will be used.
        # Intermediate directories are created if necessary.
        #
        # Optional
        # Default: os.Stdout
        #
        filePath = "${dataPath}/log/traefik.log";

        # Format is either "json" or "common".
        #
        # Optional
        # Default: "common"
        #
        # format = "json";
      };

      ################################################################
      # Access logs configuration
      ################################################################

      # Enable access logs
      # By default it will write to stdout and produce logs in the textual
      # Common Log Format (CLF), extended with additional fields.
      #
      # Optional
      #
      accessLog = {
        # Sets the file path for the access log. If not specified, stdout will be used.
        # Intermediate directories are created if necessary.
        #
        # Optional
        # Default: os.Stdout
        #
        filePath = "${dataPath}/log/access.log";
        bufferingSize = 10;

        # Format is either "json" or "common".
        #
        # Optional
        # Default: "common"
        #
        # format = "json";
      };

      ################################################################
      # API and dashboard configuration
      ################################################################
      api = {
        # Enable the API in insecure mode
        #
        # Optional
        # Default: false
        #
        # insecure = true;

        # Enabled Dashboard
        #
        # Optional
        # Default: true
        #
        dashboard = true;
      };

      ################################################################
      # Ping configuration
      ################################################################

      # Enable ping
      #ping = {
      # Name of the related entry point
      #
      # Optional
      # Default: "traefik"
      #
      # entryPoint = "traefik";
      #};

      ################################################################
      # Certificate Resolvers
      ################################################################
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            storage = "${dataPath}/acme/acme.json";
            # storage = "${config.services.traefik.dataDir}/acme.json";

            dnsChallenge = {
              provider = "cloudflare";
              delayBeforeCheck = 60;
              resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
            };
          };
        };
        letsencrypt-duckdns = {
          acme = {
            storage = "${dataPath}/acme/acme_duckdns.json";
            httpChallenge = {
              entryPoint = "web";
            };
          };
        };
      };

      ################################################################
      # Docker configuration backend
      ################################################################
      providers = {
        # Enable Docker configuration backend
        # docker = {
        #   # Docker server endpoint. Can be a tcp or a unix socket endpoint.
        #   endpoint = "unix:///var/run/docker.sock";

        #   # Default host rule.
        #   #
        #   # Optional
        #   # Default: "Host(`{{ normalize .Name }}`)"
        #   #
        #   # defaultRule = "Host(`{{ normalize .Name }}.docker.localhost`)";

        #   # Expose containers by default in traefik
        #   exposedByDefault = false;
        # };

        # file = {
        #   directory = "${dataPath}/file-provider";
        #   watch = true;
        # };
      };

      metrics = {
        prometheus = {
          addRoutersLabels = true;
        };
      };
    };
  };
}
