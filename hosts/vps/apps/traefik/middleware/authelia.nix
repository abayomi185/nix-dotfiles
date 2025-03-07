{
  services.traefik.dynamicConfigOptions = {
    http.middlewares.authelia = {
      forwardAuth = {
        address = ''http://localhost:9091/api/authz/forward-auth'';
        trustForwardHeader = true;
        authResponseHeaders = [
          "Remote-User"
          "Remote-Groups"
          "Remote-Email"
          "Remote-Name"
        ];
      };
    };
  };
}
