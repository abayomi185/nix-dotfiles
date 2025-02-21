{
  group_armDev = import ./groups/arm-dev.nix;
  group_mobileDev = import ./groups/mobile-dev.nix;
  group_awsDev = import ./groups/aws-dev.nix;
  group_azureDev = import ./groups/azure-dev.nix;

  docker = import ./docker.nix;
  sdl2 = import ./sdl2.nix;
}
