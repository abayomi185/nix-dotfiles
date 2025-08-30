{
  config,
  inputs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsAttributeSet = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/lxc/load-balancer/secrets.toml");

  internal_domain_name = secretsAttributeSet.traefik.internal_domain_name;
in {
  # configuration sample for traefik v3

  # core:
  #   defaultrulesyntax: v2

  ###############################################################
  # global configuration
  ###############################################################
  global = {
    checkNewVersion = true;
    sendAnonymousUsage = false;
  };

  ###############################################################
  # entrypoints configuration
  ###############################################################
  entryPoints = {
    web = {
      address = ":80";
      proxyProtocol.trustedIPs = ["10.13.13.1/24" "10.0.1.0/24"];
      forwardedHeaders.trustedIPs = ["10.13.13.0/24" "10.0.1.0/24"];
      # catch all redirect
      http.redirections.entryPoint = {
        to = "websecure";
        scheme = "https";
      };
    };
    websecure = {
      address = ":443";
      proxyProtocol.trustedIPs = ["10.13.13.1/24" "10.0.1.0/24"];
      forwardedHeaders.trustedIPs = ["10.13.13.1/24" "10.0.1.0/24"];
      http.tls.domains = [
        {
          main = "${internal_domain_name}";
          sans = ["*.${internal_domain_name} }}"];
        }
      ];
    };
  };

  serversTransport.insecureSkipVerify = true;

  ###############################################################
  # traefik logs configuration
  ###############################################################

  # traefik logs
  # enabled by default and log to stdout
  #
  # optional
  #
  log = {
    # log level
    level = "DEBUG";
    # level: error

    # sets the filepath for the traefik log. if not specified, stdout will be used.
    # intermediate directories are created if necessary.
    #
    # optional
    # default: os.stdout
    #
    filePath = "${config.services.traefik.dataDir}/traefik.log";

    # format is either "json" or "common".
    #
    # optional
    # default: "common"
    #
    # format = "json";
  };

  ###############################################################
  # access logs configuration
  ###############################################################

  # enable access logs
  # by default it will write to stdout and produce logs in the textual
  # common log format (clf), extended with additional fields.
  #
  # optional
  #
  accessLog = {
    # sets the file path for the access log. if not specified, stdout will be used.
    # intermediate directories are created if necessary.
    #
    # optional
    # default: os.stdout
    #
    filePath = "${config.services.traefik.dataDir}/log.txt";
    bufferingSize = 10;
    # format is either "json" or "common".
    format = "common";
  };

  ###############################################################
  # api and dashboard configuration
  ###############################################################

  # enable api and dashboard
  api = {
    # enable the api in insecure mode
    #
    # optional
    # default: false
    #
    # insecure = true;

    # enabled dashboard
    dashboard = true;
  };

  ###############################################################
  # ping configuration
  ###############################################################

  # enable ping
  #ping = {
  #  entryPoint = "traefik";
  #};

  ###############################################################
  # certificate resolvers
  ###############################################################

  certificatesResolvers = {
    letsencrypt = {
      acme = {
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "hetzner";
          propagation.delayBeforeChecks = "60";
          resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
        };
      };
    };
  };

  ###############################################################
  # docker configuration backend
  ###############################################################

  # providers = {
  #   # enable docker configuration backend
  #   docker = {
  #     endpoint = "unix:///var/run/docker.sock";
  #
  #     # default host rule.
  #     #
  #     # optional
  #     # default: "host(`{{ normalize .name }}`)"
  #     #
  #     # defaultrule = "host(`{{ normalize .name }}.docker.localhost`)";
  #
  #     # expose containers by default in traefik
  #     exposedByDefault = false;
  #   };
  #
  #   file = {
  #     directory = "/etc/traefik/file-provider";
  #     watch = true;
  #   };
  # };

  # hub:
  # tls:
  # insecure: true

  experimental.plugins."traefik-real-ip" = {
    moduleName = "github.com/soulbalz/traefik-real-ip";
    version = "v1.0.3";
  };
  # metrics:
  # prometheus:
  # addRoutersLabels: true
}
