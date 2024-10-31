{
  services.traefik.dynamicConfigOptions = {
    http.middlewares.landing_page_redirect.headers.customRequestHeaders = {
      Host = ''{{env `MEDIA_DOMAIN_NAME`}}'';
    };
  };
}
