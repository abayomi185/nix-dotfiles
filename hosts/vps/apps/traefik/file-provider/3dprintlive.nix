{
  services.traefik.dynamicConfigOptions = {
    http.routers.jellyfin = {
      rule = ''Host("3dprintlive.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "3dprintlive";
    };
    http.routers.jellyfin-secure = {
      rule = ''Host("3dprintlive.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "3dprintlive";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.jellyfin.loadBalancer.servers = [
      {url = ''https://3dprintlive.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
