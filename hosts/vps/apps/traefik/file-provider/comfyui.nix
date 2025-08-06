{
  services.traefik.dynamicConfigOptions = {
    http.routers.comfyui = {
      rule = ''Host("comfyui.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "comfyui";
    };
    http.routers.comfyui-secure = {
      rule = ''Host("comfyui.{{env `MEDIA_DOMAIN_NAME`}}")'';
      service = "comfyui";
      tls.certResolver = "letsencrypt";
      middlewares = ["global_rate_limit@file" "authelia@file"];
    };

    http.services.comfyui.loadBalancer.servers = [
      {url = ''https://comfyui.local.{{env `MEDIA_DOMAIN_NAME`}}'';}
    ];
  };
}
