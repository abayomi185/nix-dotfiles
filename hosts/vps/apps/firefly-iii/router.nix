{
  services.traefik.dynamicConfigOptions = {
    http.routers.finance = {
      rule = ''Host("finance.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "firefly-iii";
    };
    http.routers.finance-secure = {
      rule = ''Host("finance.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "firefly-iii";
      tls.certResolver = "letsencrypt";
    };

    http.services.firefly-iii.loadBalancer.servers = [
      {url = ''http://localhost:9080'';}
    ];
  };
}
