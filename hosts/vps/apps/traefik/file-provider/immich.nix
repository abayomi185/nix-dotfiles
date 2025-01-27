{
  services.traefik.dynamicConfigOptions = {
    http.routers.immich = {
      rule = ''host("immich.{{env `media_domain_name`}}")'';
      service = "immich";
    };
    http.routers.immich-secure = {
      rule = ''host("immich.{{env `media_domain_name`}}")'';
      service = "immich";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file"];
    };

    http.services.immich.loadBalancer.servers = [
      {url = ''https://immich.local.{{env `media_domain_name`}}'';}
    ];
  };
}
