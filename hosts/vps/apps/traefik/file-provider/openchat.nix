{
  services.traefik.dynamicConfigOptions = {
    http.routers.openchat = {
      rule = ''Host("chat.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "openchat";
    };
    http.routers.openchat-secure = {
      rule = ''Host("chat.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "openchat";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.openchat.loadBalancer.servers = [
      {url = ''https://chat.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
