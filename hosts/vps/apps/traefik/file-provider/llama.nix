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
      middlewares = ["global_rate_limit@file" "authelia@file"];
    };

    http.services.llama.loadBalancer.servers = [
      {url = ''http://llama.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
