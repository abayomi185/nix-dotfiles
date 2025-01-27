{
  services.traefik.dynamicConfigOptions = {
    http.routers.openchat = {
      rule = ''Host("openchat.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "openchat";
    };
    http.routers.openchat-secure = {
      rule = ''Host("openchat.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "openchat";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.openchat.loadBalancer.servers = [
      {url = ''https://openchat.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
