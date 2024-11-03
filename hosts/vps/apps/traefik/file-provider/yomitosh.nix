{
  services.traefik.dynamicConfigOptions = {
    http.routers.landing_page = {
      entryPoints = ["web"];
      rule = ''Host("{{env `MEDIA_DOMAIN_NAME`}}")'';
      middlewares = ["https_redirect"];
      service = "landing_page";
    };

    http.routers.landing_page-secure = {
      entryPoints = ["websecure"];
      rule = ''Host("{{env `MEDIA_DOMAIN_NAME`}}")'';
      middlewares = ["landing_page_redirect"];
      service = "landing_page";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = ''{{env `MEDIA_DOMAIN_NAME`}}'';
            sans = [''*.{{env `MEDIA_DOMAIN_NAME`}}''];
          }
        ];
      };
    };

    http.services.landing_page.loadBalancer.servers = [
      {url = ''https://media-club-hub.vercel.app'';}
    ];
  };
}
