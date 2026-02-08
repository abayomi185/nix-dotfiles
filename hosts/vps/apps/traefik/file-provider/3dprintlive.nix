{
  services.traefik.dynamicConfigOptions = {
    http.routers."3dprintlive" = {
      rule = ''Host("3dprintlive.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "3dprintlive";
    };
    http.routers."3dprintlive-secure" = {
      rule = ''Host("3dprintlive.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "3dprintlive";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services."3dprintlive".loadBalancer.servers = [
      {url = ''https://3dprintlive.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
