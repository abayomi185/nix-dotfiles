{
  services.traefik.dynamicConfigOptions = {
    http.routers.home = {
      rule = ''Host("home.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "home";
    };
    http.routers.home-secure = {
      rule = ''Host("home.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "home";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.home.loadBalancer.servers = [
      {url = ''https://home.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
