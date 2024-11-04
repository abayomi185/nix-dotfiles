{
  services.traefik.dynamicConfigOptions = {
    http.routers.jellyfin = {
      rule = ''Host("jellyfin.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "jellyfin";
    };
    http.routers.jellyfin-secure = {
      rule = ''Host("jellyfin.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "jellyfin";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.jellyfin.loadBalancer.servers = [
      {url = ''https://jellyfin.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
