{
  imports = [
    ./router.nix
  ];

  services.uptime-kuma = {
    enable = true;
  };
}
