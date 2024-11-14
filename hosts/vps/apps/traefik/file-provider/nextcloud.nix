{
  services.traefik.dynamicConfigOptions = {
    http.routers.nextcloud = {
      rule = ''Host("nextcloud.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "nextcloud";
    };
    http.routers.nextcloud-secure = {
      rule = ''Host("nextcloud.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "nextcloud";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.nextcloud.loadBalancer.servers = [
      {url = ''https://nextcloud.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
