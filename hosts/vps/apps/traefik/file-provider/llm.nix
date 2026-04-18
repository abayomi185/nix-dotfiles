{
  services.traefik.dynamicConfigOptions = {
    http.routers.llm = {
      rule = ''Host("llm.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "llm";
    };
    http.routers.llm-secure = {
      rule = ''Host("llm.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "llm";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file" "authelia@file"];
    };

    http.services.llm.loadBalancer.servers = [
      {url = ''http://llm.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
