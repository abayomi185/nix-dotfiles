{
  services.traefik.dynamicConfigOptions = {
    http.routers.auth = {
      rule = ''Host("auth.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "auth";
    };
    http.routers.auth-secure = {
      rule = ''Host("auth.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "auth";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.auth.loadBalancer.servers = [
      {url = ''http://localhost:9091'';}
    ];
  };
}
