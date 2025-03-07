{
  services.traefik.dynamicConfigOptions = {
    http.routers.chat = {
      rule = ''Host("chat.internal.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "chat";
    };
    http.routers.chat-secure = {
      rule = ''Host("chat.internal.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "chat";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file" "authelia@file"];
    };

    http.services.chat.loadBalancer.servers = [
      {url = ''https://chat.internal.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
