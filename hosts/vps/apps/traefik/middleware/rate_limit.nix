{
  services.traefik.dynamicConfigOptions = {
    http.middlewares.global_rate_limit.rateLimit = {
      average = 1250;
      burst = 50;
    };
  };
}
