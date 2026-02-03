{inputs, ...}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsAttributeSet = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/lxc/load-balancer/secrets.toml");

  internal_domain_name = secretsAttributeSet.traefik.internal_domain_name;
  media_domain_name = secretsAttributeSet.traefik.media_domain_name;
in {
  http = {
    ###############################################################
    # Routers
    ###############################################################
    routers = {
      # 3D Print Live
      "3dprintlive" = {
        entryPoints = ["websecure"];
        rule = ''Host("3dprintlive.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "3dprintlive";
        middlewares = ["3dprintlive-forgepath"];
      };

      # AdGuard Home
      adguard = {
        entryPoints = ["websecure"];
        rule = ''Host("adguard.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "adguard";
      };

      # AudioBookShelf
      audiobookshelf = {
        entryPoints = ["websecure"];
        rule = ''Host("audiobookshelf.${internal_domain_name}") || Host("audiobookshelf.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "audiobookshelf";
      };

      # Authelia
      authelia = {
        entryPoints = ["websecure"];
        rule = ''Host("auth.${internal_domain_name}") || Host("auth.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "authelia";
      };

      # Bazarr
      bazarr = {
        entryPoints = ["websecure"];
        rule = ''Host("bazarr.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "bazarr";
      };

      # Chat - OpenWebUI Public
      openchat = {
        entryPoints = ["websecure"];
        rule = ''Host("chat.${internal_domain_name}") || Host("chat.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "openchat";
      };

      # Chat - OpenWebUI Internal
      chat = {
        entryPoints = ["websecure"];
        rule = ''Host("chat-internal.${internal_domain_name}") || Host("chat-internal.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "chat";
      };
      chat-backend = {
        entryPoints = ["websecure"];
        rule = ''Host("chat-api.${internal_domain_name}") || Host("chat-api.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "chat-backend";
      };

      # ComfyUI
      comfyui = {
        entryPoints = ["websecure"];
        rule = ''Host("comfyui.${internal_domain_name}") || Host("comfyui.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "comfyui";
      };

      # Grafana
      grafana = {
        entryPoints = ["websecure"];
        rule = ''Host("grafana.${internal_domain_name}") || Host("grafana.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "grafana";
      };

      # Guacamole
      guacamole = {
        entryPoints = ["websecure"];
        rule = ''Host("guacamole.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "guacamole";
      };

      # Home Assistant
      home = {
        entryPoints = ["websecure"];
        rule = ''Host("home.${internal_domain_name}") || Host("home.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "home";
      };

      # Immich
      immich = {
        entryPoints = ["websecure"];
        rule = ''Host("immich.${internal_domain_name}") || Host("immich.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "immich";
      };

      # InfluxDB
      influxdb = {
        entryPoints = ["websecure"];
        rule = ''Host("influxdb.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "influxdb";
      };

      # Jellyfin
      jellyfin = {
        entryPoints = ["websecure"];
        rule = ''Host("jellyfin.${internal_domain_name}") || Host("jellyfin.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "jellyfin";
      };

      # Lidarr
      lidarr = {
        entryPoints = ["websecure"];
        rule = ''Host("lidarr.${internal_domain_name}") || Host("lidarr.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "lidarr";
      };

      # Local cert service
      local = {
        entryPoints = ["websecure"];
        rule = ''Host("cert.${internal_domain_name}") || Host("local.${media_domain_name}")'';
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "local.yomitosh.media";
              sans = ["*.local.yomitosh.media"];
            }
          ];
        };
        service = "local";
      };

      # Mainsail
      mainsail = {
        entryPoints = ["websecure"];
        rule = ''Host("mainsail.${internal_domain_name}") || Host("mainsail.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "mainsail";
      };

      # Nextcloud
      nextcloud = {
        entryPoints = ["websecure"];
        rule = ''Host("nextcloud.${internal_domain_name}") || Host("nextcloud.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        middlewares = ["nextcloud-redirectregex"];
        service = "nextcloud";
      };

      # Ombi
      ombi = {
        entryPoints = ["websecure"];
        rule = ''Host("ombi.${internal_domain_name}") || Host("ombi.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "ombi";
      };

      # Prowlarr
      prowlarr = {
        entryPoints = ["websecure"];
        rule = ''Host("prowlarr.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "prowlarr";
      };

      # Proxmox
      proxmox = {
        entryPoints = ["websecure"];
        rule = ''Host("proxmox.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "proxmox";
      };

      # Radarr
      radarr = {
        entryPoints = ["websecure"];
        rule = ''Host("radarr.${internal_domain_name}") || Host("radarr.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "radarr";
      };

      # Readarr
      readarr = {
        entryPoints = ["websecure"];
        rule = ''Host("readarr.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "readarr";
      };

      # S3 - MinIO
      s3 = {
        entryPoints = ["websecure"];
        rule = ''Host("s3.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "s3";
      };

      # Send2eReader
      send2ereader = {
        entryPoints = ["websecure"];
        rule = ''Host("send2ereader.${internal_domain_name}") || Host("send2ereader.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "send2ereader";
      };

      # Sonarr
      sonarr = {
        entryPoints = ["websecure"];
        rule = ''Host("sonarr.${internal_domain_name}") || Host("sonarr.${media_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "sonarr";
      };

      # Syncthing
      syncthing = {
        entryPoints = ["websecure"];
        rule = ''Host("syncthing.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "syncthing";
      };

      # Traefik Dashboard
      traefik = {
        entryPoints = ["websecure"];
        rule = ''Host("traefik.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "api@internal";
      };

      # Transmission
      transmission = {
        entryPoints = ["websecure"];
        rule = ''Host("transmission.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "transmission";
      };

      # Uptime Kuma
      uptime-kuma = {
        entryPoints = ["websecure"];
        rule = ''Host("uptime-kuma.${internal_domain_name}")'';
        tls.certResolver = "letsencrypt";
        service = "uptime-kuma";
      };
    };

    ###############################################################
    # Middlewares
    ###############################################################
    middlewares = {
      # Nextcloud redirect regex for .well-known URLs
      nextcloud-redirectregex = {
        redirectRegex = {
          regex = "^/.well-known/(card|cal)dav";
          replacement = "/remote.php/dav/";
          permanent = true;
        };
      };

      # 3D Print Live - force all requests to webcam path
      "3dprintlive-forgepath" = {
        replacePathRegex = {
          regex = "^/.*";
          replacement = "/webcam?action=stream";
        };
      };
    };

    ###############################################################
    # Services
    ###############################################################
    services = {
      # 3D Print Live
      "3dprintlive" = {
        loadBalancer.servers = [
          {url = "http://k1c.internal.yomitosh.media:4409";}
        ];
      };

      # AdGuard Home
      adguard = {
        loadBalancer.servers = [
          {url = "http://10.0.7.53:80";}
          {url = "http://10.0.7.53:80";}
        ];
      };

      # AudioBookShelf
      audiobookshelf = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30378";}
          {url = "http://10.0.7.42:30378";}
        ];
      };

      # Authelia
      authelia = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:8008";}
        ];
      };

      # Bazarr
      bazarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30767";}
          {url = "http://10.0.7.42:30767";}
        ];
      };

      # Chat - OpenWebUI Public
      openchat = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30281";}
          {url = "http://10.0.7.42:30281";}
          {url = "http://10.0.7.43:30281";}
        ];
      };

      # Chat - OpenWebUI Internal
      chat = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30280";}
          {url = "http://10.0.7.42:30280";}
          {url = "http://10.0.7.43:30280";}
        ];
      };
      chat-backend = {
        loadBalancer.servers = [
          {url = "http://10.0.7.250:11434";}
        ];
      };

      # ComfyUI
      comfyui = {
        loadBalancer.servers = [
          {url = "http://10.0.1.250:8188";}
        ];
      };

      # Grafana
      grafana = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:3000";}
        ];
      };

      # Guacamole
      guacamole = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:8060";}
        ];
      };

      # Home Assistant
      home = {
        loadBalancer.servers = [
          {url = "http://10.0.7.206:8123";}
        ];
      };

      # Immich
      immich = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:32283";}
          {url = "http://10.0.7.42:32283";}
        ];
      };

      # InfluxDB
      influxdb = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:8086";}
        ];
      };

      # Jellyfin
      jellyfin = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30096";}
          {url = "http://10.0.7.43:30096";}
        ];
      };

      # Lidarr
      lidarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30686";}
          {url = "http://10.0.7.42:30686";}
        ];
      };

      # Local cert service
      local = {
        loadBalancer.servers = [
          {url = "http://nop";}
        ];
      };

      # Mainsail
      mainsail = {
        loadBalancer.servers = [
          {url = "http://10.5.0.242:4409";}
        ];
      };

      # Nextcloud
      nextcloud = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30180";}
          {url = "http://10.0.7.41:30180";}
        ];
      };

      # Ombi
      ombi = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30579";}
          {url = "http://10.0.7.42:30579";}
        ];
      };

      # Prowlarr
      prowlarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30696";}
          {url = "http://10.0.7.42:30696";}
        ];
      };

      # Proxmox
      proxmox = {
        loadBalancer.servers = [
          {url = "https://10.0.7.1:8006";}
        ];
      };

      # Radarr
      radarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30078";}
          {url = "http://10.0.7.42:30078";}
        ];
      };

      # Readarr
      readarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:8787";}
          {url = "http://10.0.7.42:8787";}
        ];
      };

      # S3 - MinIO
      s3 = {
        loadBalancer.servers = [
          {url = "http://10.0.7.201:9000";}
        ];
      };

      # Send2eReader
      send2ereader = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:3031";}
        ];
      };

      # Sonarr
      sonarr = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30089";}
          {url = "http://10.0.7.42:30089";}
        ];
      };

      # Syncthing
      syncthing = {
        loadBalancer.servers = [
          {url = "https://10.0.7.41:8384";}
          {url = "https://10.0.7.42:8384";}
          {url = "https://10.0.7.43:8384";}
        ];
      };

      # Transmission
      transmission = {
        loadBalancer.servers = [
          {url = "http://10.0.7.41:30091";}
          {url = "http://10.0.7.42:30091";}
        ];
      };

      # Uptime Kuma
      uptime-kuma = {
        loadBalancer.servers = [
          {url = "http://10.0.7.205:3001";}
        ];
      };
    };
  };
}
