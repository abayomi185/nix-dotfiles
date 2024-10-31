{
  services.traefik.dynamicConfigOptions = {
    http.routers.monitoring = {
      rule = ''Host("monitoring.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "uptime-kuma";
    };
    http.routers.monitoring-secure = {
      rule = ''Host("monitoring.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "uptime-kuma";
      tls.certResolver = "letsencrypt";
    };

    http.services.uptime-kuma.loadBalancer.servers = [
      {url = ''http://localhost:3001'';}
    ];
  };
}
