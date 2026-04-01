{
  services.traefik.dynamicConfigOptions = {
    http.routers.llama = {
      rule = ''Host("llama.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "llama";
    };
    http.routers.llama-secure = {
      rule = ''Host("llama.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "llama";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.llama.loadBalancer.servers = [
      {url = "http://10.0.7.250:8080";}
    ];
  };
}
