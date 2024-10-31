{
  services.traefik.dynamicConfigOptions = {
    http.middlewares.authelia = {
      forwardAuth = {
        address = ''http://localhost:9091/api/verify?rd=https%3A%2F%2Fauth.{{env `MEDIA_DOMAIN_NAME`}}%2F'';
        # tls.insecureSkipVerify = true;
        # trustForwardHeader = true;
        authResponseHeaders = [
          "Remote-User"
          "Remote-Groups"
          "Remote-Name"
          "Remote-Email"
        ];
      };
    };
  };
}
