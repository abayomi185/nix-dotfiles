{
  services.traefik.dynamicConfigOptions = {
    http.middlewares.https_redirect.redirectScheme = {
      scheme = "https";
      permanent = true;
    };
  };
}
